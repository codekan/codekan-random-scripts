#!/bin/bash

# Dateien definieren
WORDPRESS_YAML="wordpress_test.yaml"
MYSQL_YAML="mysql_deployment.yaml"

# Prüfe, ob die Dateien existieren
for file in "$WORDPRESS_YAML" "$MYSQL_YAML"; do
  if [ ! -f "$file" ]; then
    echo "❌ Datei '$file' nicht gefunden!"
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
kubectl apply -f "$MYSQL_YAML"
kubectl apply -f "$WORDPRESS_YAML"

echo "✅ Alles deployed."
