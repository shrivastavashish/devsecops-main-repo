pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //update the content
            }
  }   
    stages {
      stage('Docker Build and Push') {
            steps {
              sh 'printenv'
              sh 'docker build -t dsocouncil/node-service:""$GIT_COMMI""T"" .'
              sh 'docker push -t dsocouncil/node-service:""$GIT_COMMIT""'
              
               }
            }
        }
    }
}
     