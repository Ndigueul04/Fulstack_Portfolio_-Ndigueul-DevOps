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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh "docker push ${FRONTEND_IMAGE}:latest"
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Déploiement des conteneurs...'

                // Arrêter tous les conteneurs qui utilisent le port 80 et 5000
                sh 'docker stop portfolio-web || true'
                sh 'docker rm portfolio-web || true'
                sh 'docker stop portfolio-frontend || true'
                sh 'docker rm portfolio-frontend || true'
                sh 'docker stop portfolio-api || true'
                sh 'docker rm portfolio-api || true'
                sh 'docker stop portfolio-backend || true'
                sh 'docker rm portfolio-backend || true'

                echo '📥 Récupération des nouvelles images...'
                sh 'docker pull cfaye876/portfolio-backend:latest'
                sh 'docker pull cfaye876/portfolio-frontend:latest'

                echo '▶️ Lancement du nouveau conteneur backend...'
                sh '''docker run -d \
                    --name portfolio-backend \
                    --restart unless-stopped \
                    --network devops_portfolio-net \
                    -e MONGO_URI=mongodb://mongodb:27017/portfolio \
                    -e PORT=5000 \
                    cfaye876/portfolio-backend:latest'''

                echo '▶️ Lancement du nouveau conteneur frontend...'
                sh '''docker run -d \
                    --name portfolio-frontend \
                    --restart unless-stopped \
                    --network devops_portfolio-net \
                    -p 80:80 \
                    cfaye876/portfolio-frontend:latest'''

                echo '✅ Conteneurs déployés avec succès !'
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