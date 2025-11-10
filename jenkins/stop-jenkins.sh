#!/bin/bash

# Script para detener Jenkins
# Para UNIR - Actividad 3

echo "🛑 Deteniendo Jenkins..."

docker-compose stop

echo "✅ Jenkins detenido"
echo ""
echo "Para iniciar nuevamente: ./start-jenkins.sh"
echo "Para eliminar todo (incluyendo datos): docker-compose down -v"
