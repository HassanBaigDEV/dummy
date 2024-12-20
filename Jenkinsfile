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
                script {
                    checkout scm: [
                        $class: 'GitSCM',
                        branches: [[name: '*/main']], // Changed from master to main
                        userRemoteConfigs: [[
                            url: 'https://github.com/HassanBaigDEV/dummy.git'
                        ]]
                    ]
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    bat 'docker-compose build' // Changed sh to bat for Windows
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    bat 'docker-compose up -d'
                    bat 'timeout /t 30 /nobreak' // Changed sleep to Windows timeout
                    bat 'curl http://localhost:3000'
                    bat 'docker-compose down'
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASS')]) {
                        bat "docker login -u %DOCKER_HUB_USER% -p %DOCKER_HUB_PASS%"
                        bat "docker tag php-app-web:latest %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%"
                        bat "docker push %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%"
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    bat 'docker-compose down || exit 0'
                    bat 'docker-compose pull'
                    bat 'docker-compose up -d'
                }
            }
        }
    }
    
    post {
        always {
            bat 'docker-compose down || exit 0'
            bat 'docker logout'
            cleanWs() // Clean workspace after build
        }
    }
}