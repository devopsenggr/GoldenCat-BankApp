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
                    sh '''git config user.email "awstraining42@gmail.com"
                    git config user.name "devopsenggr"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    echo $BUILD_NUMBER
                    sed -i "s/goldencatbankapp:${imageTag}/$goldencatbankapp:${BUILD_NUMBER}/" deployment-service.yml
                    git add deployment-service.yml
                    git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                    git push https://${github-token}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} main'''
                }
                
            }
        }
