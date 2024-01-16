pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr:'2'))
        disableConcurrentBuilds()
        timeout (time: 60, unit: 'MINUTES')
        timestamps()
      }
     parameters {
        choice(
            choices: ['DEV', 'QA','SANDBOX', 'PROD'], 
            name: 'Environment'
          )
        string(
            defaultValue: '0.0.0',
            name: 'tag',
            description: '''Please enter dev image tag to be used''',
         )

    }
    environment {
        IMAGE_NAME = "battleboat-cicd"    
        DOCKERHUB_ID = "geovie19"
        EXPOSE_PORT="8181"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    }
     stages {
        stage('Checkout') {
            steps {
                script {
                    checkout([$class: 'GitSCM', 
                              branches: [[name: 'main']], 
                              doGenerateSubmoduleConfigurations: false, 
                              extensions: [], 
                              submoduleCfg: [], 
                              userRemoteConfigs: [[url: 'https://github.com/geovie19/Battleboat-cicd.git']]])
                }
            }
        }
        stage('Print Workspace Contents') {
    steps {
        script {
            sh 'ls -al ${WORKSPACE}'
        }
    }
}
                                              
    
        stage('Check Syntax - Dockerfile'){
          steps{
             script {
                    sh '''
                    
                       docker run -v ${WORKSPACE}:${WORKSPACE}/project hadolint/hadolint hadolint ${WORKSPACE}/project/Dockerfile
                           
                    '''
               }
            }
          }
        stage('SonarQube analysis') {
           when{  
            expression {
              params.Environment == 'DEV' }
              }
               agent {
                 docker {
                 image 'sonarsource/sonar-scanner-cli:4.8'
                 }
             }
               environment {
                 CI = 'true'
                  scannerHome='/opt/sonar-scanner'
            }
             steps{
               withSonarQubeEnv('Sonarqube') {
                 sh "${scannerHome}/bin/sonar-scanner"
                }
              }
            }

          stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true }
            }
        }
        stage('Build image') {
           when{  
            expression {
              params.Environment == 'DEV' }
              }
            steps {
                script {
                    sh '''
                     docker build -t ${DOCKERHUB_ID}/${IMAGE_NAME}:${BUILD_NUMBER}-$tag .
                    '''
                }
            }
        }
         stage('Scan Image with  SNYK') {
            agent any
            when{  
            expression {
              params.Environment == 'DEV' }
              }
            environment{
                SNYK_TOKEN = credentials('snyktoken')
            }
            steps {
                script{
                    sh '''
                    echo "Starting Image scan $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER} ..." 
                    echo There is Scan result : 
                    SCAN_RESULT=$(docker run --rm -e SNYK_TOKEN=$SNYK_TOKEN -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/app snyk/snyk:docker snyk test --docker $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag --json ||  if [ $? -gt "1" ];then echo -e "Warning, you must see scan result \n" ;  false; elif [ $? -eq "0" ]; then   echo "PASS : Nothing to Do"; elif [ $? -eq "1" ]; then   echo "Warning, passing with something to do";  else false; fi)
                    echo "Scan ended"
                    '''
                }
            }
        }
         stage('Run container based on build image') {
          agent any
          steps {
            script {
              sh '''
                  echo "Cleaning existing container if exist"
                  docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                  docker run --name $IMAGE_NAME -d -p $EXPOSE_PORT:80  ${DOCKERHUB_ID}/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                  sleep 5
              '''
             }
          }
       }
         stage('test image') {
           when{  
            expression {
              params.Environment == 'DEV' }
              }
            steps {
                script {
                    sh '''
                        curl -v 172.17.0.1:$EXPOSE_PORT | grep -i "Stats"
                      '''
                }
            }
        }
        /*stage('Clean container') {
          agent any
            when{  
            expression {
              params.Environment == 'DEV' }
              }
          steps {
             script {
               sh '''
                   docker stop $IMAGE_NAME
                   docker rm $IMAGE_NAME
               '''
             }
          }
        }*/
        stage('Login Dockerhub') {
            steps {
                script {
                    sh '''
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_ID --password-stdin
                      '''
                }
            }
         }
         stage('Push image to Dockerhub') {
           when{  
            expression {
              params.Environment == 'DEV' }
              }
            steps {
                script {
                    sh '''
                        docker push $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                      '''
                }
            }
        }
         /*stage('Pull and tag image QA') {
           when{  
            expression {
              params.Environment == 'QA' }
              }
            steps {
                script {
                    sh '''
                        docker pull $DOCKERHUB_ID/$IMAGE_NAME:$tag
                        docker tag $DOCKERHUB_ID/$IMAGE_NAME:$tag $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                        
                      '''
                }
            }
        }
         stage('Pull and tag image SANDBOX') {
           when{  
            expression {
              params.Environment == 'SANDBOX' }
              }
            steps {
                script {
                    sh '''
                        docker pull $DOCKERHUB_ID/$IMAGE_NAME:$tag
                        docker tag $DOCKERHUB_ID/$IMAGE_NAME:$tag $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                      '''
                }
            }
        }
        stage('Pull and tag image PROD') {
           when{  
            expression {
              params.Environment == 'PROD' }
              }
            steps {
                script {
                    sh '''
                        docker pull $DOCKERHUB_ID/$IMAGE_NAME:$tag
                        docker tag $DOCKERHUB_ID/$IMAGE_NAME:$tag $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                        
                      '''
                }
            }
        }*/
        stage('Update DEV manifest') {
         when{  
            expression {
              params.Environment == 'DEV' }
              }
            steps {
              sh '''
                git config --global user.email 'carolle.matchum@yahoo.com' && git config --global user.name 'carollebertille'
                rm -rf deployment-battleboat  || true
                git clone git@github.com:carollebertille/deployment-battleboat.git
                cd deployment-battleboat/overlays/dev/battleboat  && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                git commit -am 'Publish new dev release' && git push
              '''
            }
        }
       /*stage('Update QA manifest') {
          when{  
            expression {
              params.Environment == 'QA' }
              }
            steps {
                sh '''
                git config --global user.email 'carolle.matchum@yahoo.com' && git config --global user.name 'carollebertille'
                rm -rf deployment-battleboat  || true
                git clone git@github.com:carollebertille/deployment-battleboat.git
                cd deployment-battleboat/overlays/qa/battleboat  && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                git commit -am 'Publish new qa release' && git push
              '''
            }
        }
        stage('Update sandbox manifest') {
          when{  
            expression {
              params.Environment == 'SANDBOX' }
              }
            steps {
                sh '''
                 git config --global user.email 'carolle.matchum@yahoo.com' && git config --global user.name 'carollebertille'
                rm -rf deployment-battleboat  || true
                git clone git@github.com:carollebertille/deployment-battleboat.git
                cd deployment-battleboat/overlays/sandbox/battleboat  && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                git commit -am 'Publish new sandbox release' && git push
              '''
            }
        }
        stage('Update PROD manifest') {
          when{  
            expression {
              params.Environment == 'PROD' }
              }
            steps {
                sh '''
                git config --global user.email 'carolle.matchum@yahoo.com' && git config --global user.name 'carollebertille'
                rm -rf deployment-battleboat  || true
                git clone git@github.com:carollebertille/deployment-battleboat.git
                cd deployment-battleboat/overlays/prod/battleboat  && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}-$tag
                git commit -am 'Publish new prod release' && git push
              '''
            }
        }*/
        stage('Wait for Argocd') {
            steps {
                script {
                 echo "wait for argocd"
                }
            }
        }
         stage('Find xss vulnerability'){
          steps{
             script {
                    sh '''
                       docker run -v ${WORKSPACE}:${WORKSPACE}/attack gauntlt/gauntlt gauntlt ${WORKSPACE}/attack/attack/xss.attack
                    '''
               }
            }
          }
 }
 
}
