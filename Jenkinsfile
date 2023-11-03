pipeline {
    agent any

    environment {
        imageName = "dsocouncil/node-service:${GIT_COMMIT}"
        githubRepoURL = 'https://github.com/shrivastavashish/devsecops-main-repo.git'
        sonarProjectKey = 'devsecops'
        sonarHostUrl = 'http://54.89.224.127:9000/'
        sonarToken = 'sqp_a75e8fe4cf8f67f1bada216f7e5d3c799c893a32'
        dockerImageName = "dsocouncil/node-service:${env.GIT_COMMIT}"
    }

    stages {
        stage('Build Artifact') {
            steps {
                script {
                    sh "mvn clean package -DskipTests=true"
                    archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
                }
            }
        }

        stage('Check Git-Secrets') {
            steps {
                script {
                    sh "rm trufflehog || true"
                    sh """
                    docker run --rm -v \"$PWD:/pwd\" \
                    trufflesecurity/trufflehog:latest github --repo ${githubRepoURL} --json > trufflehog_report.json
                    """
                    sh "sudo cp trufflehog_report.json /root/reports/trufflehog/"
                }
            }
        }

        stage('Static Analysis - SonarQube') {
            steps {
                script {
                    withSonarQubeEnv('devsecops') {
                        sh "mvn sonar:sonar -Dsonar.projectKey=${sonarProjectKey} -Dsonar.host.url=${sonarHostUrl} -Dsonar.login=${sonarToken}"
                    }
                }
            }
        }

        stage('SCA Scan - Dependency-Check') {
            steps {
                sh "mvn dependency-check:check"
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "bash trivy-scan.sh"
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: "dockerhub", url: "https://index.docker.io/v1/") {
                        sh "sudo docker build -t ${dockerImageName} ."
                        sh "docker push ${dockerImageName}"
                    }
                }
            }
        }

        stage('Kubernetes - Vulnerability Scan') {
            steps {
                parallel(
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-kuber-scan.sh"
                    }
                )
            }
        }

        stage('Kubernetes- CIS Benchmark') {
            steps {
                parallel(
                    "Master": {
                        sh "bash cis-master.sh"
                    },
                    "Etcd": {
                        sh "bash cis-etcd.sh"
                    },
                    "Kubelet": {
                        sh "bash cis-kubelet.sh"
                    }
                )
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "cp k8s_deployment_service.yaml k8s_deployment_service_temp.yaml"
                    sh "sed -i 's#replace#${imageName}#g' k8s_deployment_service_temp.yaml"
                    sh "kubectl apply -f k8s_deployment_service_temp.yaml"
                    sh "rm k8s_deployment_service_temp.yaml"
                }
            }
        }
    }
}
