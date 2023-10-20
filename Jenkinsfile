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
              sh 'printenv'
              sh "docker push dsocouncil/node-service:${env.GIT_COMMIT}"
              sh 'docker push -t dsocouncil/node-service:""$GIT_COMMIT""'
              
               }
            }
        }
    }