pipeline { 
    agent any
    
    
    stages {
        
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('CodeCheckOutforUpdate') {
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
                    sh '''
                    set -x
                    git config --global user.email "awstraining42@gmail.com"
                    git config --global user.name "devopsenggr"
                    sed -i "s|goldencatbankapp:.*|$goldencatbankapp:${BUILD_NUMBER}|g" deployment-service.yml
                    git add .
                    git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                    git push -u origin main
                    git push https://${github-token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main
                   #git push --set-upstream origin main
                    '''
                }
                
            }
        }
        
    }
}
