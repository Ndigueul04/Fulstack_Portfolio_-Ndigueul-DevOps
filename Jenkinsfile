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

                echo '🛑 Arrêt de l ancien conteneur backend...'
                sh 'docker stop portfolio-backend || true'

                echo '🗑️ Suppression de l ancien conteneur backend...'
                sh 'docker rm portfolio-backend || true'

                echo '🛑 Arrêt de l ancien conteneur frontend...'
                sh 'docker stop portfolio-frontend || true'

                echo '🗑️ Suppression de l ancien conteneur frontend...'
                sh 'docker rm portfolio-frontend || true'

                echo '📥 Récupération de la nouvelle image backend...'
                sh 'docker pull cfaye876/portfolio-backend:latest'

                echo '📥 Récupération de la nouvelle image frontend...'
                sh 'docker pull cfaye876/portfolio-frontend:latest'

                echo '▶️ Lancement du nouveau conteneur backend...'
                sh 'docker run -d --name portfolio-backend --restart unless-stopped -p 5000:5000 cfaye876/portfolio-backend:latest'

                echo '▶️ Lancement du nouveau conteneur frontend...'
                sh 'docker run -d --name portfolio-frontend --restart unless-stopped -p 80:80 cfaye876/portfolio-frontend:latest'

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