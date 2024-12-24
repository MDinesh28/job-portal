pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "mdinesh28"
        DOCKER_IMAGE = "job-portal"
        DOCKER_CREDENTIALS = credentials('docker-hub')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MDinesh28/job-portal.git'
            }
        }

        stage('Build and Test') {
            steps {
                sh '/opt/maven/apache-maven-3.9.9/bin/mvn compile'
                sh '/opt/maven/apache-maven-3.9.9/bin/mvn package'
                sh '/opt/maven/apache-maven-3.9.9/bin/mvn install'
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
        withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
            sh """
                sed -i 's|image: .*|image: ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}|' manifests/deployment.yaml
                git config user.email "mekadinesh28@gmail.com"
                git config user.name "Jenkins"
                
                git init
                git remote remove origin || true
                git remote add origin https://github.com/MDinesh28/portal.git
                
                git add .
                git commit -am "Update image tag to ${BUILD_NUMBER}"

                # Ensure main branch exists and is tracked
                git checkout -b main || git checkout main
                git branch --set-upstream-to=origin/main main
                
                git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/MDinesh28/portal.git main --set-upstream origin main
            """
        }
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
