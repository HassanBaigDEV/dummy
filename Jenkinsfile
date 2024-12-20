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
                // Checkout code from GitHub
                git 'https://github.com/HassanBaigDEV/dummy.git'
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    // Build Docker images using docker-compose
                    sh 'docker-compose build'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    // Start the containers
                    sh 'docker-compose up -d'
                    
                    // Wait for services to be ready
                    sh 'sleep 30'
                    
                    // Add your test commands here
                    // Example: sh 'curl http://localhost:3000'
                    
                    // Stop containers
                    sh 'docker-compose down'
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub
                    sh 'echo $DOCKER_HUB_CREDS_PSW | docker login -u $DOCKER_HUB_CREDS_USR --password-stdin'
                    
                    // Tag and push the image
                    sh "docker tag php-app-web:latest ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    // Pull latest image and deploy
                    sh 'docker-compose down || true'
                    sh 'docker-compose pull'
                    sh 'docker-compose up -d'
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'docker-compose down || true'
            sh 'docker logout'
        }
    }
}