// ========================================
// PIPELINE CI/CD - FinTech Solutions S.A.
// Actividad 3 - UNIR EIEC
// ========================================
// Este pipeline automatiza el ciclo de vida del software
// incluyendo: Build, Unit Tests, API Tests y E2E Tests

pipeline {
    // Definir el agente donde se ejecutará el pipeline
    agent any
    
    // Definición de las etapas del pipeline
    stages {
        
        // ====================================
        // ETAPA 1: Obtención del Código Fuente
        // ====================================
        stage('Source') {
            steps {
                echo 'Clonando repositorio desde GitHub...'
                // Clona el repositorio Git
                git 'https://github.com/andrespesantez/unir-cicd.git'
            }
        }
        
        // ====================================
        // ETAPA 2: Construcción (Build)
        // ====================================
        stage('Build') {
            steps {
                echo '🔨 Building stage!'
                // Ejecuta el comando make build que construye las imágenes Docker
                // Ver Makefile para detalles: construye calculator-app y calc-web
                sh 'make build'
            }
        }
        
        // ====================================
        // ETAPA 3: Pruebas Unitarias
        // ====================================
        stage('Unit tests') {
            steps {
                echo 'Running unit tests...'
                // Ejecuta las pruebas unitarias con pytest
                // Genera cobertura y reportes en formato XML
                sh 'make test-unit'
                
                // Archiva los resultados XML para histórico
                // Estos archivos estarán disponibles en Jenkins UI
                archiveArtifacts artifacts: 'results/*.xml'
            }
        }
        
        // ====================================
        // ETAPA 4: Pruebas de API (NUEVA)
        // ====================================
        stage('API tests') {
            steps {
                echo 'Running API tests...'
                // Ejecuta pruebas de integración de la API REST
                // Levanta el servidor Flask y ejecuta pytest con marca @api
                sh 'make test-api'
                
                // Archiva específicamente el resultado de las pruebas API
                archiveArtifacts artifacts: 'results/api_result.xml'
            }
        }
        
        // ====================================
        // ETAPA 5: Pruebas End-to-End (NUEVA)
        // ====================================
        stage('E2E tests') {
            steps {
                echo 'Running E2E tests...'
                // Ejecuta pruebas end-to-end con Cypress
                // Levanta frontend (Nginx) + backend (Flask) + Cypress
                sh 'make test-e2e'
                
                // Archiva todos los resultados XML generados
                archiveArtifacts artifacts: 'results/*.xml'
            }
        }
    }
    
    // ====================================
    // ACCIONES POST-EJECUCIÓN
    // ====================================
    post {
        
        // Se ejecuta SIEMPRE, independientemente del resultado
        always {
            echo 'Procesando resultados de pruebas...'
            
            // Publica los resultados de JUnit para visualización en Jenkins
            // Genera gráficos y tendencias de las pruebas
            // Busca todos los archivos *_result.xml (unit, api, e2e)
            junit 'results/*_result.xml'
            
            // Limpia el workspace para liberar espacio
            cleanWs()
        }
        
        // Se ejecuta SOLO si el pipeline FALLA
        failure {
            // Mensaje de debug en consola
            echo "Pipeline FAILED - Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER}"
            
            // ====================================
            // NOTIFICACIÓN POR EMAIL (REQUISITO)
            // ====================================
            // Envía email SOLO en caso de fallo
            // Incluye: nombre del trabajo + número de ejecución
            
            // IMPORTANTE: Comentar este bloque si Jenkins no tiene SMTP configurado
            // Para testing: descomentar solo el 'echo' de arriba
            
            // Envío de correo en caso de fallo
            // VERSIÓN SIN EMAIL - Solo muestra en consola
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
            // Comentar la siguiente línea si Jenkins no está configurado para enviar emails
            // emailext(
            //     subject: "Pipeline FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
            //     body: """
            //         <h2>Pipeline Execution Failed</h2>
            //         <p><strong>Job Name:</strong> ${env.JOB_NAME}</p>
            //         <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
            //         <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
            //         <p><strong>Status:</strong> FAILED</p>
            //         <p>Please check the console output for more details.</p>
            //     """,
            //     to: 'devops@fintech-solutions.com',
            //     mimeType: 'text/html'
            // )
        }
        
        // OPCIONAL: Se puede añadir notificación de éxito también
        // success {
        //     echo "Pipeline SUCCESS - Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER}"
        // }
        
        // OPCIONAL: Para casos de tests fallidos pero build exitoso
        // unstable {
        //     echo "Pipeline UNSTABLE - Some tests failed"
        // }
    }
}

// ========================================
// VARIABLES DE ENTORNO DISPONIBLES
// ========================================
// Las siguientes variables están disponibles en todo el pipeline:
//
// ${env.JOB_NAME}        - Nombre del job (ej: "FinTech-CI-Pipeline")
// ${env.BUILD_NUMBER}    - Número de build (ej: "42")
// ${env.BUILD_ID}        - ID del build (generalmente igual a BUILD_NUMBER)
// ${env.BUILD_URL}       - URL completa del build en Jenkins
// ${env.WORKSPACE}       - Ruta del workspace en el nodo
// ${env.NODE_NAME}       - Nombre del nodo donde se ejecuta
// ${env.GIT_COMMIT}      - Hash del commit de Git
// ${env.GIT_BRANCH}      - Rama de Git
// ${currentBuild.result} - Resultado actual: SUCCESS, FAILURE, UNSTABLE, etc.
//
// ========================================
// HERRAMIENTAS ÚTILES DE JENKINS
// ========================================
//
// 1. Pipeline Syntax Generator:
//    - Disponible en: [Job] → Pipeline Syntax
//    - Genera código para steps complejos
//
// 2. Global Variable Reference:
//    - Disponible en: [Job] → Pipeline Syntax → Global Variables Reference
//    - Lista todas las variables y objetos disponibles
//
// 3. Snippet Generator:
//    - Para generar código de plugins (emailext, archiveArtifacts, etc.)
//
// ========================================
// NOTAS PARA TESTING
// ========================================
//
// 1. Si Jenkins NO tiene SMTP configurado:
//    - Comentar el bloque 'emailext'
//    - Usar solo el 'echo' para verificar las variables
//
// 2. Para simular fallos y probar el email:
//    - Añadir: sh 'exit 1' en cualquier stage
//    - El pipeline fallará y ejecutará post.failure
//
// 3. Para ver variables disponibles:
//    - Añadir stage de debug con: sh 'env | sort'
//
// ========================================
