#!/bin/bash

# Remover server.pid
echo "Removendo server.pid..."
rm -f tmp/pids/server.pid

# Criar diretório para assets
echo "Criando diretório para assets..."
mkdir -p app/assets/builds
touch app/assets/builds/.keep

# Compilar assets do Tailwind
echo "Compilando assets do Tailwind..."
bin/rails tailwindcss:build

# Preparar banco de dados
echo "Preparando banco de dados..."
bin/rails db:prepare

# Iniciar servidor Rails
echo "Iniciando servidor Rails..."
bin/rails server -b 0.0.0.0