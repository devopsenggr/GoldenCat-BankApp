pipeline { 
    agent any
    
    
    stages {
               
        
        stage('Update Deployment file') 
        {
            environment 
            {
                GIT_REPO_NAME = "GoldenCat-BankApp"
                GIT_USER_NAME = "devopsenggr"
            }
            git branch: 'main', url: 'https://github.com/devopsenggr/GoldenCat-BankApp.git'
            steps 
            {
              withCredentials([usernameColonPassword(credentialsId: 'github', variable: 'github-token')]) 
                {
                    script
                    {
                    set -x
                    git config --global user.email "awstraining42@gmail.com"
                    git config --global user.name "devopsenggr"
                    git checkout main
                    sed -i "s|goldencatbankapp:.*|$goldencatbankapp:${BUILD_NUMBER}|g" deployment-service.yml
                    git add .
                    git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                    git push https://${github-token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:master
                    }
                }
            }
                
            }//stage
        }//stages
        
    }//pipe
