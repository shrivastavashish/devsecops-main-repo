pipeline {
    agent any
    stages {
        stage('Build Artifact') {
            steps {
                script {
                    sh "mvn clean package -DskipTests=true"
                    archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
                }
            }
        }

        stage('SonarQube - SAST') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh "mvn sonar:sonar -Dsonar.projectKey=secopsdev-application -Dsonar.host.url=http://opssecdev.eastus.cloudapp.azure.com:9000 -Dsonar.login=sqp_fe345569b7450bf4edf58ff82ce881f10a387f24"
                    }
                }
                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('SCA Scan - Dependency-Check') {
            steps {
                script {
                    sh "mvn dependency-check:check"
                }
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                }
            }
        }

        // stage('Snyk Code Scan') {
        //     steps {
        //         script {
        //             // Set the SNYK_TOKEN environment variable
        //             withEnv(["SNYK_TOKEN=56355cf5-fcf9-4a2a-91d6-50057a2e8038"]) {
        //                 echo 'Testing...'
        //                 snykSecurity(
        //                     snykInstallation: 'snykdso',
        //                     snykTokenId: 'snykdso',
        // //                     // Place other parameters here as needed
        //                 )
        //             }
        //         }
        //     }
        // }

        stage('Trivy Scan') {
            steps {
                script {
                    // Run Trivy for vulnerability scanning
                    sh "bash trivy-scan.sh"
                } 
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    def dockerImageName = "dsocouncil/node-service:${env.GIT_COMMIT}"

                    withDockerRegistry(credentialsId: "dockerhub", url: "https://index.docker.io/v1/") {
                        sh "docker build -t ${dockerImageName} ."
                        sh "docker push ${dockerImageName}"
                    }
                }
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                        sh "cp k8s_deployment_service.yaml k8s_deployment_service_temp.yaml"
                        sh "sed -i 's#replace#dsocouncil/node-service:${GIT_COMMIT}#g' k8s_deployment_service_temp.yaml"
                        sh "kubectl apply -f k8s_deployment_service_temp.yaml"
                        sh "rm k8s_deployment_service_temp.yaml"
                    }
                }
            }
        }
    }
}
