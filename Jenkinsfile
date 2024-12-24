pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "mdinesh28"
        DOCKER_IMAGE = "job-portal"
        DOCKER_CREDENTIALS = credentials('docker-hub')
        // Go to Jenkins Dashboard → Manage Jenkins → Credentials.
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
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
