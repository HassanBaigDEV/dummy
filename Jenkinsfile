pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
        DOCKER_IMAGE_NAME = 'hassanb9/php-app'
        DOCKER_IMAGE_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            steps {
                bat 'docker-compose build --no-cache'
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    try {
                        bat 'docker-compose up -d'
                        // Windows PowerShell sleep command
                        powershell 'Start-Sleep -s 30'
                        // Health check
                        bat 'powershell Invoke-WebRequest -Uri http://localhost:3000 -UseBasicParsing'
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
                        powershell Start-Sleep -s 10
                        powershell Invoke-WebRequest -Uri http://localhost:3000 -UseBasicParsing
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