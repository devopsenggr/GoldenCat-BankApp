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
        
        stage('Compile') {
            steps {
            sh  "mvn compile"
            }
        }
        
        
        stage('Package') {
            steps {
                sh "mvn package"
            }
        }
                stage('Sonarqube Analysis') {
            steps {
                
                    withSonarQubeEnv('sonar-server') {
                        sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=GoldenCAtBank \
                        -Dsonar.projectKey=GoldenCatBank \
                        -Dsonar.java.binaries=target'''
                    }
               
            }
        }
        
        
        stage('Trivy File Scan') {
            steps {
                    sh 'trivy fs . > trivyfs.txt'
                  }
        } 
        
        stage('publishArtifactoryToNexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                        sh "mvn deploy"
                }
                
            }
        }
        
        stage('Docker BuildTag and push') {
            steps {
                script
                {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') 
                    {
                        sh'docker build -t awsd43/goldencatbankapp:${BUILD_NUMBER} .'
                        sh 'docker push awsd43/goldencatbankapp:${BUILD_NUMBER}'
                    }
                }
            }
        } 
        stage("TRIVY Image Scan") {
            steps {
                sh 'trivy image awsd43/goldencatbankapp:${BUILD_NUMBER} > trivyimage.txt' 
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
