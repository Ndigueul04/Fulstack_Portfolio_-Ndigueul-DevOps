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

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Analyse de la qualité du code...'
                withSonarQubeEnv('sonarqube') {
                    withEnv(["PATH+SONAR=${tool 'sonar-scanner'}/bin"]) {
                        sh '''
                            sonar-scanner \
                            -Dsonar.projectKey=portfolio \
                            -Dsonar.projectName="Portfolio FullStack" \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/node_modules/**,**/dist/**
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '🔎 Vérification du Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
                    --network docker_portfolio-net \
                    -e MONGODB_URI=mongodb://portfolio-mongo:27017/portfolio \
                    -e PORT=5000 \
                    cfaye876/portfolio-backend:latest'''

                echo '▶️ Lancement du nouveau conteneur frontend...'
                sh '''docker run -d \
                    --name portfolio-frontend \
                    --restart unless-stopped \
                    --network docker_portfolio-net \
                    -p 80:80 \
                    cfaye876/portfolio-frontend:latest'''

                echo '✅ Conteneurs déployés avec succès !'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline terminé avec succès !'
            mail to: 'serignecheikhndigueulfaye@gmail.com',
                 subject: "✅ Pipeline réussi : ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Bonjour,\n\nLe pipeline ${env.JOB_NAME} build #${env.BUILD_NUMBER} a réussi !\n\nVoir les détails : ${env.BUILD_URL}\n\nCordialement,\nJenkins"
        }
        failure {
            echo '❌ Pipeline échoué !'
            mail to: 'serignecheikhndigueulfaye@gmail.com',
                 subject: "❌ Pipeline échoué : ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Bonjour,\n\nLe pipeline ${env.JOB_NAME} build #${env.BUILD_NUMBER} a échoué !\n\nVoir les détails : ${env.BUILD_URL}\n\nCordialement,\nJenkins"
        }
    }
}