#!/bin/bash
set -e

echo "🧹 Starte automatisches Cleanup aller Kubernetes-Ressourcen aus YAML-Dateien im aktuellen Verzeichnis..."

# Alle YAML-Dateien im aktuellen Verzeichnis (ohne Unterordner)
YAML_FILES=(*.yaml *.yml)

if [ ${#YAML_FILES[@]} -eq 0 ]; then
  echo "❌ Keine YAML-Dateien im aktuellen Verzeichnis gefunden. Abbruch."
  exit 1
fi

# Hilfsfunktion: Einmalig kubectl delete mit --ignore-not-found auf eine Resource ausführen
function delete_resource() {
  local kind=$1
  local name=$2

  if [[ -n "$kind" && -n "$name" ]]; then
    echo "   Lösche $kind/$name"
    kubectl delete "$kind" "$name" --ignore-not-found
  fi
}

# 1. Ressourcen aus YAML-Dateien auslesen (metadata.name & kind)
for file in "${YAML_FILES[@]}"; do
  echo "🔍 Verarbeite Datei: $file"

  # Mehrere YAML-Dokumente in einer Datei behandeln
  # Anzahl der Dokumente herausfinden
  docs_count=$(yq e 'length' "$file" 2>/dev/null || echo 1)

  # Für jede Ressource die Art (kind) und den Namen (metadata.name) auslesen und löschen
  # yq '... | select(.kind != null) | .kind' gibt alle kinds
  # yq '... | select(.metadata.name != null) | .metadata.name' gibt alle Namen

  # Besser: mit --doc Flag von yq alle docs nacheinander behandeln
  # (Cloud Shell hat yq Version 4+, Syntax angepasst)

  doc_index=0
  while true; do
    kind=$(yq e "select(document_index == $doc_index) | .kind" "$file" 2>/dev/null)
    name=$(yq e "select(document_index == $doc_index) | .metadata.name" "$file" 2>/dev/null)

    if [[ "$kind" == "null" && "$name" == "null" ]]; then
      break
    fi

    if [[ -n "$kind" && -n "$name" && "$kind" != "null" && "$name" != "null" ]]; then
      delete_resource "$kind" "$name"
    fi

    ((doc_index++))
  done
done

# 2. Alle referenzierten Secrets aus den YAML-Dateien finden und löschen
# Suchen nach "secretKeyRef.name" in allen YAML-Dateien
echo "🔍 Suche nach referenzierten Secrets in YAML..."

referenced_secrets=$(yq e '.. | select(has("secretKeyRef")) | .secretKeyRef.name' "${YAML_FILES[@]}" | sort -u)

for secret in $referenced_secrets; do
  echo "   Lösche Secret/$secret"
  kubectl delete secret "$secret" --ignore-not-found
done

echo "✅ Cleanup abgeschlossen!"
