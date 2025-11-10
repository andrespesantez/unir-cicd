#!/bin/bash

# Script de configuración y arranque de Jenkins
# Para UNIR - Actividad 3

set -e

echo "🚀 Iniciando configuración de Jenkins para UNIR-CICD..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

print_info "✅ Docker está instalado"

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

print_info "✅ Docker Compose está instalado"

# Verificar que Docker está corriendo
if ! docker info &> /dev/null; then
    print_error "Docker no está corriendo. Por favor inicia Docker."
    exit 1
fi

print_info "✅ Docker está corriendo"

# Crear directorios necesarios si no existen
mkdir -p jenkins_home
print_info "📁 Directorios creados"

# Detener contenedores anteriores si existen
print_info "🛑 Deteniendo contenedores existentes..."
docker-compose down 2>/dev/null || true

# Construir y levantar servicios
print_info "🔨 Construyendo imágenes Docker..."
docker-compose build

print_info "🚀 Levantando servicios..."
docker-compose up -d

# Esperar a que Jenkins esté listo
print_info "⏳ Esperando a que Jenkins inicie (esto puede tardar 1-2 minutos)..."
sleep 20

# Intentar obtener la contraseña inicial
MAX_RETRIES=30
RETRY_COUNT=0
JENKINS_PASSWORD=""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker exec jenkins-controller test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        JENKINS_PASSWORD=$(docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
        if [ ! -z "$JENKINS_PASSWORD" ]; then
            break
        fi
    fi
    sleep 5
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
done

echo ""

# Mostrar información de acceso
echo ""
echo "=========================================="
echo "✅ Jenkins está listo!"
echo "=========================================="
echo ""
echo "📍 URL: http://localhost:8080"
echo ""

if [ ! -z "$JENKINS_PASSWORD" ]; then
    echo "🔑 Contraseña inicial de administrador:"
    echo "   $JENKINS_PASSWORD"
    echo ""
    echo "💾 También puedes obtenerla con:"
    echo "   docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword"
else
    print_warning "No se pudo obtener la contraseña automáticamente."
    print_info "Ejecuta: docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword"
fi

echo ""
echo "=========================================="
echo "📚 Próximos pasos:"
echo "=========================================="
echo ""
echo "1. Abre http://localhost:8080 en tu navegador"
echo "2. Ingresa la contraseña de administrador"
echo "3. Selecciona 'Install suggested plugins'"
echo "4. Crea tu usuario administrador"
echo "5. Crea un nuevo job de tipo 'Pipeline'"
echo "6. Copia el contenido de Jenkinsfile.actividad3.groovy"
echo ""
echo "📋 Comandos útiles:"
echo "   Ver logs:     docker-compose logs -f jenkins"
echo "   Detener:      docker-compose stop"
echo "   Iniciar:      docker-compose start"
echo "   Eliminar:     docker-compose down"
echo "   Eliminar todo: docker-compose down -v"
echo ""
echo "🌐 SonarQube (opcional): http://localhost:9000"
echo "   Usuario: admin / Contraseña: admin"
echo ""
