pipeline {
    agent any
    tools 
    {
        maven 'maven3'
        jdk 'jdk17'
    }
    
    parameters 
    {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Choose which environment to deploy: Blue or Green')
        choice(name: 'DOCKER_TAG', choices: ['blue', 'green'], description: 'Choose the Docker image tag for the deployment')
        booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch traffic between Blue and Green')
    }
    
    environment 
    {
        IMAGE_NAME = "awsd43/blogapp"
        TAG = "${params.DOCKER_TAG}"  // The image tag now comes from the parameter
        KUBE_NAMESPACE = 'webapps'
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout')
         {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/devopsenggr/fullstack-blogapp.git'
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
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                        sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=blogapp \
                        -Dsonar.projectKey=blogapp \
                        -Dsonar.java.binaries=target'''
                    }
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        stage('publishArtifactoryToNexus') 
        {
            steps 
            {
                withMaven(globalMavenSettingsConfig: 'myglobalsettings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) 
                {
                        sh "mvn deploy"
                }
                
            }
        }
        stage('Docker build') 
        {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                    }
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html ${IMAGE_NAME}:${TAG}"
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push ${IMAGE_NAME}:${TAG}"
                    }
                }
            }
        }
        
               
        stage('Deploy SVC-APP') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: 'dev-medium-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://617BC1EDEF36BE179A29EEC81DE27231.gr7.us-east-1.eks.amazonaws.com') {
                        sh """ if ! kubectl get svc blogapp-service -n ${KUBE_NAMESPACE}; then
                                kubectl apply -f blogapp-service.yml -n ${KUBE_NAMESPACE}
                              fi
                        """
                   }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def deploymentFile = ""
                    if (params.DEPLOY_ENV == 'blue') 
                    {
                        deploymentFile = 'app-deployment-blue.yml'
                    } 
                    else
                    {
                        deploymentFile = 'app-deployment-green.yml'
                    }

                    withKubeConfig(caCertificate: '', clusterName: 'dev-medium-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://617BC1EDEF36BE179A29EEC81DE27231.gr7.us-east-1.eks.amazonaws.com') 
                    {
                        sh "kubectl apply -f ${deploymentFile} -n ${KUBE_NAMESPACE}"
                    }
                }
            }
        }
        
        stage('Switch Traffic Between Blue & Green Environment') 
        {
            when 
            {
                expression { return params.SWITCH_TRAFFIC }
            }
            steps {
                script {
                    def newEnv = params.DEPLOY_ENV

                    // Always switch traffic based on DEPLOY_ENV
                    withKubeConfig(caCertificate: '', clusterName: 'dev-medium-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://617BC1EDEF36BE179A29EEC81DE27231.gr7.us-east-1.eks.amazonaws.com') 
                    {
                        sh '''
                            kubectl patch service blogapp-service -p "{\\"spec\\": {\\"selector\\": {\\"app\\": \\"bankapp\\", \\"version\\": \\"''' + newEnv + '''\\"}}}" -n ${KUBE_NAMESPACE}
                        '''
                    }
                    echo "Traffic has been switched to the ${newEnv} environment."
                }
            }
        }
        
        stage('Verify Deployment')
        {
            steps {
                script {
                    def verifyEnv = params.DEPLOY_ENV
                    withKubeConfig(caCertificate: '', clusterName: 'dev-medium-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://617BC1EDEF36BE179A29EEC81DE27231.gr7.us-east-1.eks.amazonaws.com') 
                    {   """
                        kubectl get pods -l version=${verifyEnv} -n ${KUBE_NAMESPACE}
                        kubectl get svc blogapp-service -n ${KUBE_NAMESPACE}
                        """
                    }
                }
            }
        }
    }//stages
}//pipeline
