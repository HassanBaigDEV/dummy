t-hubh-credentials')
        DOCKER_IMAGE_NAME = 'hassanb9/php-app'
        DOCKER_IMAGE_TAG = 'latest'
        POWERSHELL_PATH =e 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            steps {
                bat 'docker-compose build --no-cache's
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    try {
                        bat 'docker-compose up -d'
                        // Use full PowerShell path
                        bat "${env.POWERSHELL_PATH}e -Command Start-Sleep -s 30"
                        // Health check using curl instead
                        bat 'curl - f http://localhost:3000'
                    } catch (Exception e) {
                        bat 'docker-compose logs'
                        error "Test stage failed: ${e.message}"
                    } finally {
                        bat 'docker-compose down'
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                                    passwordVariable: 'DOCKER_PASSWORD', 
                                                    usernameVariable: 'DOCKER_USERNAME')]) {
                        bat """
                            echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                            docker tag php-app-web:latest %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%
                            docker push %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%
                        """
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    bat """
                        docker-compose down || exit 0
                        docker-compose pull
                        docker-compose up -d
                        ${env.POWERSHELL_PATH} -Command Start-Sleep -s 10
                        curl -f http://localhost:3000
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                bat 'docker-compose down || exit 0'
                bat 'docker logout || exit 0'
                cleanWs()
            }
        }
        failure {
            script {
                bat 'docker-compose logs'
            }
        }
    }
}