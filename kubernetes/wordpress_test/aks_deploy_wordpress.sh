#!/bin/bash

set -e

echo "=== AKS Deployment Helper ==="

# Eingabe Resource Group & Clustername
read -p "Azure Resource Group: " RESOURCE_GROUP
read -p "AKS Cluster Name: " AKS_CLUSTER

echo "🔑 Anmeldung bei Azure..."
az account show >/dev/null 2>&1 || az login

echo "⏳ Lade AKS Credentials für Cluster '$AKS_CLUSTER' in Resource Group '$RESOURCE_GROUP'..."
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER" --overwrite-existing

# Prüfe, ob kubectl konfiguriert ist
if ! kubectl version --short >/dev/null 2>&1; then
  echo "❌ kubectl ist nicht richtig konfiguriert. Abbruch."
  exit 1
fi

# Dateien definieren
WORDPRESS_YAML="wordpress_test.yaml"
MYSQL_YAML="mysql_deployment.yaml"

# Prüfe, ob Dateien existieren
for file in "$WORDPRESS_YAML" "$MYSQL_YAML"; do
  if [ ! -f "$file" ]; then
    echo "❌ Datei '$file' nicht gefunden! Bitte lade die YAML-Dateien in das Verzeichnis hoch."
    exit 1
  fi
done

# Secrets abfragen
echo "🔐 Bitte Passwörter eingeben:"
read -s -p "MySQL root password: " MYSQL_ROOT_PASSWORD
echo
read -s -p "WordPress DB password: " WORDPRESS_DB_PASSWORD
echo

# Secret löschen falls vorhanden und neu erstellen
kubectl delete secret wp-secrets --ignore-not-found
kubectl create secret generic wp-secrets \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=wordpress-db-password="$WORDPRESS_DB_PASSWORD"

# Deployments anwenden
echo "🚀 Deploy MySQL..."
kubectl apply -f "$MYSQL_YAML"
echo "🚀 Deploy WordPress..."
kubectl apply -f "$WORDPRESS_YAML"

echo "✅ Deployment abgeschlossen!"
