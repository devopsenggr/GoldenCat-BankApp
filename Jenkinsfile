pipeline { 
    agent any
    
    tools {
        maven 'maven3'
        jdk 'jdk17'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        
        
        
        stage('CodeCheckOut') {
            steps {
           git branch: 'main', url: 'https://github.com/devopsenggr/GoldenCat-BankApp.git'
            }
        }
        stage('Update Deployment file') 
        {
            environment 
            {
                GIT_REPO_NAME = "GoldenCat-BankApp"
                GIT_USER_NAME = "devopsenggr"
            }
            steps 
            {
               
                withCredentials([usernameColonPassword(credentialsId: 'github', variable: 'github-token')])
                {
                    sh '''git config user.email "awstraining42@gmail.com"
                    git config user.name "devopsenggr"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    echo $BUILD_NUMBER
                    imageTag=$(grep -oP '(?<=GoldenCat-BankApp:)[^ ]+' deployment-service.yaml)
                    echo $imageTag
                    sed -i "s/goldencatbankapp:${imageTag}/$goldencatbankapp:${BUILD_NUMBER}/" deployment-service.yaml
                    git add deployment-service.yaml
                    git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                    git push https://${github-token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master'''
                }
                
            }
        }
        
    }
}
