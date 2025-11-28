# FinTech Solutions CI/CD Pipeline

Este repositorio contiene la implementación de un pipeline de Integración y Entrega Continua (CI/CD) utilizando Jenkins para una aplicación web. El proyecto automatiza el ciclo de vida completo del software, desde la construcción hasta las pruebas exhaustivas (Unitarias, API y E2E).

## Características

- **Pipeline Declarativo**: Definido completamente en un `Jenkinsfile` para control de versiones y fácil mantenimiento.
- **Construcción Dockerizada**: Utiliza Docker para construir y aislar el entorno de la aplicación.
- **Testing Integral**:
    - **Unit Tests**: Validación de lógica interna con `pytest`.
    - **API Tests**: Pruebas de integración de endpoints REST.
    - **E2E Tests**: Pruebas de extremo a extremo simulando interacción de usuario.
- **Gestión de Artefactos**: Recolección automática de resultados de pruebas en formato XML (JUnit).
- **Notificaciones Inteligentes**: Sistema de notificación de fallos que proporciona detalles contextuales (Job, Build ID, URL) directamente en los logs (simulación de email).

## Pre-requisitos

Para ejecutar este pipeline, necesitas un entorno con:

- **Jenkins**: Servidor de automatización (versión 2.x o superior).
- **Docker**: Instalado en el nodo/agente donde se ejecutará el pipeline.
- **Make**: Herramienta de construcción (incluida en la mayoría de sistemas Unix/Linux).
- **Git**: Para clonar el repositorio.

## Instalación y Configuración

Sigue estos pasos para configurar el pipeline en tu servidor Jenkins:

1.  **Crear un Nuevo Job**:
    - En el Dashboard de Jenkins, selecciona **"Nueva Tarea" (New Item)**.
    - Ingresa el nombre: `FinTech-Solutions-CI-Pipeline`.
    - Selecciona el tipo **Pipeline**.
    - Haz clic en **OK**.

2.  **Configurar el Pipeline**:
    - Desplázate a la sección **Pipeline**.
    - En **Definition**, selecciona **Pipeline script**.
    - Copia y pega el contenido del archivo `Jenkinsfile` (ver abajo o en el repositorio) en el editor.
    - Haz clic en **Guardar**.

## Ejecución

1.  Ve a la página principal del Job creado.
2.  Haz clic en **"Construir Ahora" (Build Now)** en el menú lateral.
3.  Observa el progreso en el **Stage View**.
4.  Al finalizar, puedes ver los resultados de las pruebas en la sección **Test Result**.

## Estructura del Pipeline

El pipeline está diseñado con las siguientes etapas secuenciales:

| Etapa | Descripción | Comando Ejecutado |
|-------|-------------|-------------------|
| **Source** | Clona el código fuente desde el repositorio. | `git clone ...` |
| **Build** | Construye las imágenes Docker de la aplicación. | `make build` |
| **Unit Tests** | Ejecuta pruebas unitarias y genera reportes. | `make test-unit` |
| **API Tests** | Levanta un entorno efímero y prueba la API REST. | `make test-api` |
| **E2E Tests** | Despliega la app completa y ejecuta pruebas Cypress. | `make test-e2e` |

### Acciones Post-Ejecución

-   **Always**: Se procesan los reportes JUnit (`results/*_result.xml`) y se limpia el espacio de trabajo (`cleanWs()`).
-   **Failure**: Si el pipeline falla, se imprime una notificación detallada en la consola simulando un correo electrónico de alerta.

## Jenkinsfile

```groovy
pipeline {
    agent any
    
    stages {
        stage('Source') {
            steps {
                echo 'Clonando repositorio desde GitHub...'
                git 'https://github.com/andrespesantez/unir-cicd.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building stage!'
                sh 'make build'
            }
        }
        
        stage('Unit tests') {
            steps {
                echo 'Running unit tests...'
                sh 'make test-unit'
                archiveArtifacts artifacts: 'results/*.xml'
            }
        }
        
        stage('API tests') {
            steps {
                echo 'Running API tests...'
                sh 'make test-api'
                archiveArtifacts artifacts: 'results/api_result.xml'
            }
        }
        
        stage('E2E tests') {
            steps {
                echo 'Running E2E tests...'
                sh 'make test-e2e'
                archiveArtifacts artifacts: 'results/*.xml'
            }
        }
    }
    
    post {
        always {
            echo 'Procesando resultados de pruebas...'
            junit 'results/*_result.xml'
            cleanWs()
        }
        
        failure {
            echo "Pipeline FAILED - Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER}"
            
            echo "========================================="
            echo "PIPELINE FAILED - EMAIL NOTIFICATION"
            echo "========================================="
            echo "Job Name: ${env.JOB_NAME}"
            echo "Build Number: ${env.BUILD_NUMBER}"
            echo "Build URL: ${env.BUILD_URL}"
            echo "========================================="
            echo "Email that would be sent:"
            echo "To: devops@fintech-solutions.com"
            echo "Subject: Pipeline FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}"
            echo "Body: "
            echo "         <h2>Pipeline Execution Failed</h2>"
            echo "         <p><strong>Job Name:</strong> ${env.JOB_NAME}</p>"
            echo "         <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>"
            echo "         <p><strong>Build URL:</strong> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>"
            echo "         <p><strong>Status:</strong> FAILED</p>"
            echo "         <p>Please check the console output for more details.</p>"
            echo "========================================="
        }
    }
}
```

## Solución de Problemas Comunes

-   **Error de Permisos Docker**: Asegúrate de que el usuario `jenkins` tenga permisos para ejecutar comandos Docker (`usermod -aG docker jenkins`).
-   **Puertos Ocupados**: El pipeline incluye comandos de limpieza, pero si falla inesperadamente, es posible que debas detener contenedores manualmente (`docker stop ...`).
-   **Falta de SMTP**: La notificación por correo está simulada en los logs para evitar dependencias de servidores de correo externos en entornos de laboratorio.

---
**Proyecto realizado para el Máster en DevOps - UNIR**

