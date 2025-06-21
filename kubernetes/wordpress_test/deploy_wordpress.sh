#!/bin/bash

#Das Bash Script gibt Secrets für das Kubernetes Deployment mit

# Setze Dateiname der Deployment YAML
DEPLOYMENT_FILE="wordpress_test.yaml"

# Prüfe ob die Datei existiert
if [ ! -f "$DEPLOYMENT_FILE" ]; then
  echo "❌ Deployment-Datei '$DEPLOYMENT_FILE' nicht gefunden!"
  exit 1
fi

# Eingabe der Secrets
echo "🔐 Bitte Passwörter für WordPress und MySQL eingeben:"
read -s -p "MySQL root password: " MYSQL_ROOT_PASSWORD
echo
read -s -p "WordPress DB password: " WORDPRESS_DB_PASSWORD
echo

# Secret erstellen (alte Version ggf. löschen)
kubectl delete secret wp-secrets --ignore-not-found

echo "📦 Erstelle Kubernetes Secret 'wp-secrets'..."
kubectl create secret generic wp-secrets \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=wordpress-db-password="$WORDPRESS_DB_PASSWORD"

# Deployment ausführen
echo "🚀 Wende Deployment aus '$DEPLOYMENT_FILE' an..."
kubectl apply -f "$DEPLOYMENT_FILE"

echo "✅ Fertig! WordPress + Secrets sind deployed."
