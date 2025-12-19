## Jenkins to Kubernetes (kubeadm) CI/CD Pipeline Documentation

This documentation outlines the automation of a Java application deployment using a Jenkins Pipeline, Docker for containerization, and a kubeadm-managed Kubernetes cluster for orchestration.

---

### 1. Objective

The Jenkins pipeline automates the complete CI/CD lifecycle:

1. **Continuous Integration:** Pulls code from GitHub and builds the Java artifact using Maven.
2. **Containerization:** Packages the application into a Docker image.
3. **Delivery:** Pushes the container image to Docker Hub.
4. **Continuous Deployment:** Updates the Kubernetes cluster with the new image version using `kubectl`.

---

### 2. Prerequisites

#### 2.1 Infrastructure

| Component | Requirement |
| --- | --- |
| **Jenkins Server** | Ubuntu EC2 Instance |
| **Kubernetes Cluster** | kubeadm (1 Master + 1 Worker) |
| **Image Registry** | Docker Hub Account |
| **Source Control** | GitHub Repository containing code, Dockerfile, and K8s manifests |

#### 2.2 Software on Jenkins Server

The following binaries must be installed and available in the system PATH:

* Java (11 or 17)
* Maven
* Docker
* kubectl
* Git

**Verify Installation:**

```bash
java -version
mvn -version
docker --version
kubectl version --client
git --version

```

---

### 3. Required Jenkins Plugins

Install these via **Manage Jenkins** > **Plugins** > **Available Plugins**:

* **Pipeline:** Orchestrates the Jenkinsfile stages.
* **Git:** Allows Jenkins to clone the repository.
* **Docker Pipeline:** Provides syntax for Docker commands.
* **Credentials Binding:** Allows secure handling of passwords and keys.
* **Kubernetes CLI:** Enables `kubectl` interactions from the pipeline.

---

### 4. Jenkins Credentials Setup

#### 4.1 Docker Hub Credentials

1. Navigate to **Manage Jenkins** > **Credentials** > **System** > **Global credentials** > **Add Credentials**.
2. **Kind:** Username with password.
3. **ID:** `dockerhub-creds` (This must match the ID in your Jenkinsfile).
4. **Username/Password:** Your Docker Hub account details.

#### 4.2 Kubernetes Access (kubeconfig)

To allow Jenkins to deploy to the cluster, the Jenkins user needs the `admin.conf` from the Master node.
On the Jenkins server:

```bash
mkdir -p ~/.kube
# Securely copy the configuration from your Master node
scp ubuntu@<MASTER_IP>:/etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

```

**Verify:** `kubectl get nodes` should list your master and worker nodes.

---

### 5. Git Repository Structure

Ensure your repository is organized as follows:

```text
Java-Login-App/
├── Dockerfile          # Instructions to containerize the app
├── pom.xml             # Maven dependencies and build config
├── Jenkinsfile         # The CI/CD pipeline script
└── k8s/                # Kubernetes manifest folder
    ├── deployment.yaml # Pod and ReplicaSet definitions
    ├── service.yaml    # Internal/External networking
    └── ingress.yaml    # URL-based routing (Optional)

```

---

### 6. Pipeline Stage Breakdown

#### Stage 1: Checkout Code

Pulls the latest source code from the specified GitHub branch to ensure the environment is up to date.

#### Stage 2: Build Application

Executes `mvn clean package`. This compiles the Java code and creates a `.war` or `.jar` file in the `target/` directory.

#### Stage 3: Build Docker Image

Uses the `Dockerfile` at the root of the project to create a container image tagged as `latest`.

#### Stage 4: Push Docker Image

Authenticates with Docker Hub using the stored credentials and uploads the image. The use of `--password-stdin` ensures that passwords do not appear in plain text in Jenkins console logs.

#### Stage 5: Deploy to Kubernetes

Applies the YAML manifests located in the `k8s/` folder. This triggers Kubernetes to pull the new image from Docker Hub and perform a rolling update of the application pods.

---

### 7. Complete Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        // Replace with your Docker Hub username and repository name
        DOCKER_IMAGE = "yourdockerhubuser/java-login"
        DOCKER_CREDS = "dockerhub-creds"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/USERNAME/Java-Login-App.git'
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                  kubectl apply -f k8s/ingress.yaml
                '''
            }
        }
    }
}

```

---

### 8. Post-Deployment Verification

After a successful pipeline run, execute these commands on the **Master Node** or **Jenkins Server** to verify the state of the cluster:

* **Pods:** `kubectl get pods` (Status should be `Running`).
* **Service:** `kubectl get svc` (Check for the `NodePort` value).
* **Application Access:**
* **NodePort:** `http://<WORKER_PUBLIC_IP>:30080/<context-path>`

 ---
