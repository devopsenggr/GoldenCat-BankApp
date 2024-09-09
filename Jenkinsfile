pipeline { 
    agent any
    
    tools {
        maven 'maven3'
        jdk 'jdk17'
    }
     stages {
        
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }       
            
        stage('CodeCheckOutForUpdate') {
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
               
                withCredentials([gitUsernamePassword(credentialsId: 'github', gitToolName: 'Default')]) {
                    sh '''
                    set +e
                    git config user.email "awstraining42@gmail.com"
                    git config user.name "devopsenggr"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    echo $BUILD_NUMBER
                   sed -i "s/goldencatbankapp:.* /goldencatbankapp:${BUILD_NUMBER}/g" deployment-service.yml
                    git add .
                    git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                    git push https://${github-token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                }
                
            }

        }
     }
}
            
