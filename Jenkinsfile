pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'ctonn3000'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        GIT_COMMIT_SHORT = "${env.GIT_COMMIT[0..7]}"
        IMAGE_TAG = "${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from repository"
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build Cast Service') {
                    steps {
                        script {
                            echo "Building Cast Service Docker image"
                            sh """
                                cd cast-service
                                docker build -t ${DOCKER_REGISTRY}/cast-service:${IMAGE_TAG} .
                                docker tag ${DOCKER_REGISTRY}/cast-service:${IMAGE_TAG} ${DOCKER_REGISTRY}/cast-service:latest
                            """
                        }
                    }
                }
                stage('Build Movie Service') {
                    steps {
                        script {
                            echo "Building Movie Service Docker image"
                            sh """
                                cd movie-service
                                docker build -t ${DOCKER_REGISTRY}/movie-service:${IMAGE_TAG} .
                                docker tag ${DOCKER_REGISTRY}/movie-service:${IMAGE_TAG} ${DOCKER_REGISTRY}/movie-service:latest
                            """
                        }
                    }
                }
            }
        }
        
        stage('Test Services') {
            parallel {
                stage('Test Cast Service') {
                    steps {
                        script {
                            echo "Testing Cast Service"
                            sh """
                                # Start container for testing
                                docker run -d --name cast-test-${BUILD_NUMBER} -p 8081:80 ${DOCKER_REGISTRY}/cast-service:${IMAGE_TAG}
                                sleep 10
                                
                                # Health check
                                curl -f http://localhost:8081/api/v1/casts/docs || exit 1
                                
                                # Cleanup
                                docker stop cast-test-${BUILD_NUMBER}
                                docker rm cast-test-${BUILD_NUMBER}
                            """
                        }
                    }
                }
                stage('Test Movie Service') {
                    steps {
                        script {
                            echo "Testing Movie Service"
                            sh """
                                # Start container for testing
                                docker run -d --name movie-test-${BUILD_NUMBER} -p 8082:80 ${DOCKER_REGISTRY}/movie-service:${IMAGE_TAG}
                                sleep 10
                                
                                # Health check
                                curl -f http://localhost:8082/api/v1/movies/docs || exit 1
                                
                                # Cleanup
                                docker stop movie-test-${BUILD_NUMBER}
                                docker rm movie-test-${BUILD_NUMBER}
                            """
                        }
                    }
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    echo "Pushing Docker images to DockerHub"
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            
                            # Push Cast Service
                            docker push ${DOCKER_REGISTRY}/cast-service:${IMAGE_TAG}
                            docker push ${DOCKER_REGISTRY}/cast-service:latest
                            
                            # Push Movie Service
                            docker push ${DOCKER_REGISTRY}/movie-service:${IMAGE_TAG}
                            docker push ${DOCKER_REGISTRY}/movie-service:latest
                            
                            docker logout
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Dev') {
            steps {
                script {
                    echo "Deploying to Development environment"
                    withCredentials([file(credentialsId: 'config', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\$KUBECONFIG_FILE
                            
                            # Create namespace if not exists
                            kubectl apply -f k8s/namespaces.yaml
                            
                            # Deploy Cast Service
                            helm upgrade --install cast-dev charts/cast-service \\
                                --namespace dev \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=1 \\
                                --wait
                            
                            # Deploy Movie Service
                            helm upgrade --install movie-dev charts/movie-service \\
                                --namespace dev \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=1 \\
                                --wait
                        """
                    }
                }
            }
        }
        
        stage('Deploy to QA') {
            steps {
                script {
                    echo "Deploying to QA environment"
                    withCredentials([file(credentialsId: 'config', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\$KUBECONFIG_FILE
                            
                            # Deploy Cast Service
                            helm upgrade --install cast-qa charts/cast-service \\
                                --namespace qa \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=2 \\
                                --wait
                            
                            # Deploy Movie Service
                            helm upgrade --install movie-qa charts/movie-service \\
                                --namespace qa \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=2 \\
                                --wait
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    echo "Deploying to Staging environment"
                    withCredentials([file(credentialsId: 'config', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\$KUBECONFIG_FILE
                            
                            # Deploy Cast Service
                            helm upgrade --install cast-staging charts/cast-service \\
                                --namespace staging \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=3 \\
                                --wait
                            
                            # Deploy Movie Service
                            helm upgrade --install movie-staging charts/movie-service \\
                                --namespace staging \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=3 \\
                                --wait
                        """
                    }
                }
            }
        }
        
        stage('Manual Approval for Production') {
            steps {
                script {
                    echo "Waiting for manual approval for Production deployment"
                    input message: 'Deploy to Production?', 
                          ok: 'Deploy',
                          parameters: [
                              choice(name: 'DEPLOY_TO_PROD', 
                                   choices: ['Yes', 'No'], 
                                   description: 'Do you want to deploy to Production?')
                          ]
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                expression { params.DEPLOY_TO_PROD == 'Yes' }
            }
            steps {
                script {
                    echo "Deploying to Production environment"
                    withCredentials([file(credentialsId: 'config', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\$KUBECONFIG_FILE
                            
                            # Deploy Cast Service
                            helm upgrade --install cast-prod charts/cast-service \\
                                --namespace prod \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=5 \\
                                --wait
                            
                            # Deploy Movie Service
                            helm upgrade --install movie-prod charts/movie-service \\
                                --namespace prod \\
                                --set image.tag=${IMAGE_TAG} \\
                                --set replicaCount=5 \\
                                --wait
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Cleaning up Docker images"
                // Use environment variables if available, fallback to hardcoded values
                def dockerRegistry = env.DOCKER_REGISTRY ?: 'ctonn3000'
                def imageTag = env.IMAGE_TAG ?: "${env.BUILD_NUMBER}-${env.GIT_COMMIT[0..7]}"
                
                sh """
                    # Clean up local images to save space
                    docker rmi ${dockerRegistry}/cast-service:${imageTag} || true
                    docker rmi ${dockerRegistry}/movie-service:${imageTag} || true
                    docker rmi ${dockerRegistry}/cast-service:latest || true
                    docker rmi ${dockerRegistry}/movie-service:latest || true
                    
                    # Remove test containers if they exist
                    docker rm -f cast-test-${env.BUILD_NUMBER} || true
                    docker rm -f movie-test-${env.BUILD_NUMBER} || true
                """
            }
        }
        success {
            echo "Pipeline completed successfully! 🎉"
        }
        failure {
            echo "Pipeline failed! 😞 Check the logs for details."
            mail to: "fall-lewis.y@datascientest.com",
                 subject: "${env.JOB_NAME} - Build # ${env.BUILD_ID} has failed",
                 body: "Pipeline failed. Check console at ${env.BUILD_URL}"
        }
    }
}