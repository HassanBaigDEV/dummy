pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'hassanb9/php-app'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        passwordVariable: 'DOCKER_PASSWORD',
                        usernameVariable: 'DOCKER_USERNAME'
                    )]) {
                        bat "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    try {
                        bat 'docker pull php:8.1-apache'
                        bat 'docker-compose build --no-cache'
                    } catch (Exception e) {
                        error "Build failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    try {
                        bat 'docker-compose up -d'
                        bat 'timeout /t 30 /nobreak'
                        bat 'curl -f http://localhost:3000'
                    } finally {
                        bat 'docker-compose down'
                    }
                }
            }
        }
        
        stage('Push') {
            steps {
                bat "docker tag php-app-web:latest ${DOCKER_IMAGE}:${DOCKER_TAG}"
                bat "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }
        
        stage('Deploy') {
            steps {
                bat '''
                    docker-compose down || exit 0
                    docker-compose pull
                    docker-compose up -d
                    timeout /t 10 /nobreak
                    curl -f http://localhost:3000
                '''
            }
        }
    }
    
    post {
        always {
            bat 'docker-compose down || exit 0'
            bat 'docker logout || exit 0'
            cleanWs()
        }
        failure {
            bat 'docker-compose logs || exit 0'
        }
    }
}