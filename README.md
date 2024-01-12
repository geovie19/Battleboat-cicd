# Battleboat-cicd
=======
# Deployment of Battleboat application through the CI/CD Pipeline with security measures

## 1. **Context**
   
   * Deployment of battleboat application through the CI / CD
   
   * Implementation of security measures
   
   * Notification system

## 2. **Tools**
       * AWS: Ec2, EKS
       * Source Code Management: Github
       * Build Server: Jenkins 
       * Kustomize
       * Security: Haolint, Sonarqube and Snyk                                         
       * Notification: Slack
       * Continuous delivery: ArgoCD  
       
       
## 3. **Infrastructure**
We wanted to reproduce an enterprise-type infrastructure with 3 servers and kubeadm with one control plane and one worker node

- ** Master Jenkins server:**
A master server Jenkins scheduling build jobs, monitor the target server
- ** Build server:**
A build server(target server) to build our docker images, tests, and scan images
- ** Argocd:**
  Argo CD is an open-source declarative continuous delivery (CD) tool for Kubernetes. It helps automate the deployment of applications to Kubernetes clusters 
  while ensuring the desired state matches the actual state of the cluster. Argo CD uses Git repositories as the source of truth for declarative infrastructure 
  and application definitions.
- ** Sonarqube server:**
SonarQube is an open-source platform for continuous inspection of code quality

## 4. **Description of tools**
- Jenkins is an open-source automation server that facilitates continuous integration (CI) and continuous delivery (CD) of software projects. It enables 
  developers to automate various stages of the software development lifecycle, including building, testing, and deploying applications
- Docker is an open-source platform that automates the deployment, scaling, and management of applications in lightweight, portable containers.
- Dockerhub: registry to store docker imges
- Snyk is a popular developer-first security platform that helps developers find and fix vulnerabilities in their open-source dependencies and container 
  images.Here are some key
- Slack collaborative platform used to notify us of the state of the pipeline
- SonarQube is an open-source platform developed by SonarSource for continuous inspection of code quality. SonarQube does static code analysis, which provides a 
  detailed report of bugs, code smells, vulnerabilities, code duplications.
- Hadolint  is a tool for linting Dockerfiles. It checks Dockerfiles against a set of best practices to ensure they are efficient, secure, and follow 
  recommended conventions. 
## 4. **Installation tools** 
- Install jenkins https://www.jenkins.io/doc/book/installing/linux/
- Install sonarqube https://docs.sonarsource.com/sonarqube/latest/setup-and-upgrade/install-the-server/
- Create snyk account https://snyk.io/
- Create dockerhub account: https://hub.docker.com/
- ArgoCD: https://argo-cd.readthedocs.io/en/stable/getting_started/
- Kustomize: https://kubectl.docs.kubernetes.io/installation/kustomize/
  

## 4. **Workflow**

CI/CD pipeleine, we have 4 environments(dev, qa, prepro,pro) and each environment have the pipeline

In order to fully understand the workfow, let's take the following scenario:

- Developer makes a modification to the code from their workstation and pushes it on github

- Thanks to the webhook, the modification is received on the jenkins server and the build of the project can begin

- jenkins use the docker agent to launch hadolint container to check Dockerfile syntax and the analyzse result sent back to jenkins

- jenkins use the docker agent to launch sonarqube scannercli container to analyse the code and the scan result sent back to jenkins

- Jenkins sent the build report to sonarqube server to be compared with quality gate

- sonarqube sent the code analysis result back to jenkins

- jenkins read dockerfile to build image and invoke snyk to scan it
### Keywords
