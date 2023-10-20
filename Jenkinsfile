pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
      }
    }

    stage('Docker Build and Push') {
      steps {
        script {
          // Define the Docker image name with the GIT_COMMIT as the tag
          def dockerImageName = "dsocouncil/node-service:${env.GIT_COMMIT}"

          // Authenticate with Docker Hub and push the image
          withDockerRegistry(credentialsId: "dockerhub", url: "https://index.docker.io/v1/") {
            sh "docker build -t ${dockerImageName} ."
            sh "docker push ${dockerImageName}"
          }
        }
      }
    }
  }
}