pipeline {
    agent any
    
    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'hassanb9/php-app'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                bat 'docker-compose build --no-cache'
            }
        }
        
        stage('Test') {
            steps {
                script {
                    try {
                        bat 'docker-compose up -d'
                        bat 'timeout /t 30 /nobreak'
                        bat 'curl -f http://localhost:3000'
                    } catch (Exception e) {
                        bat 'docker-compose logs'
                        error "Test failed: ${e.message}"
                    } finally {
                        bat 'docker-compose down'
                    }
                }
            }
        }
        
        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
                    bat 'docker tag php-app-web:latest %DOCKER_IMAGE%:%DOCKER_TAG%'
                    bat 'docker push %DOCKER_IMAGE%:%DOCKER_TAG%'
                }
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
            bat 'docker-compose logs'
        }
    }
}