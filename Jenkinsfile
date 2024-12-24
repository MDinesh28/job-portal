pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "your-docker-registry"
        DOCKER_IMAGE = "job-portal"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MDinesh28/job-portal.git'
            }
        }

        stage('Build and Test') {
            steps {
                sh 'mvn compile'
                sh 'mvn package'
                sh 'mvn install'
            }
        }

        stage('Package') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        stage('Scan Docker Image') {
            steps {
                sh """
                    trivy image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                sh """
                    sed -i 's|image: .*|image: ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}|' manifests/deployment.yaml
                    git config user.email "your-email@example.com"
                    git config user.name "Jenkins"
                    git commit -am "Update image tag to ${BUILD_NUMBER}"
                    git push
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f manifests/
                """
            }
        }
    }

    post {
        always {
            slackSend channel: '#devops', message: "Pipeline ${currentBuild.fullDisplayName} finished with status: ${currentBuild.currentResult}"
        }
    }
}
