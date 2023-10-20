pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //update the content
            }
  }   
      stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t dsocouncil/node-service:""$GIT_COMMIT"" .'
          sh 'docker push dsocouncil/node-service:""$GIT_COMMIT""'
              
               }
        }
      }
    }
  }
    