pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'cfaye876'
        BACKEND_IMAGE = "${DOCKERHUB_USERNAME}/portfolio-backend"
        FRONTEND_IMAGE = "${DOCKERHUB_USERNAME}/portfolio-frontend"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Récupération du code source...'
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                echo '🔨 Build de l image backend...'
                sh "docker build -t ${BACKEND_IMAGE}:latest ./backend"
            }
        }

        stage('Build Frontend') {
            steps {
                echo '🔨 Build de l image frontend...'
                sh "docker build -t ${FRONTEND_IMAGE}:latest ./frontend"
            }
        }

        stage('Push Images') {
            steps {
                echo '📤 Push des images sur Docker Hub...'
                sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh "docker push ${FRONTEND_IMAGE}:latest"
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Déploiement des conteneurs...'
                sh "docker compose -f docker-compose.yml down"
                sh "docker compose -f docker-compose.yml up -d"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline terminé avec succès !'
        }
        failure {
            echo '❌ Pipeline échoué !'
        }
    }
}