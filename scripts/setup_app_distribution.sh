#!/bin/bash

# Firebase App Distribution Setup Script
# Este script configura o App Distribution no Firebase para o projeto

echo "🔧 Configurando Firebase App Distribution..."

# Verificar se Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI não encontrado. Instalando..."
    npm install -g firebase-tools
fi

# Verificar se está logado
echo "🔑 Verificando autenticação Firebase..."
if ! firebase projects:list &> /dev/null; then
    echo "🔑 Fazendo login no Firebase..."
    firebase login
fi

echo "📱 Configurando App Distribution..."

# Verificar se o projeto está configurado
PROJECT_ID="nemideia-87363"
APP_ID="1:733461658307:android:7bcbec2e0928eb28884076"

echo "📋 Projeto: $PROJECT_ID"
echo "📱 App ID: $APP_ID"

# Criar grupo de testadores
echo "👥 Criando grupo de testadores..."
firebase appdistribution:groups:create --app $APP_ID --display-name "Testers" --alias "testers" || echo "Grupo 'testers' já existe"

echo "✅ Configuração do Firebase App Distribution concluída!"
echo ""
echo "📝 Próximos passos:"
echo "1. Adicione testadores ao grupo 'testers' no Firebase Console"
echo "2. Execute um release teste: ./quick_release.sh patch 'Teste inicial'"
echo "3. Configure os secrets do GitHub Actions (se necessário)"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID/appdistribution"
