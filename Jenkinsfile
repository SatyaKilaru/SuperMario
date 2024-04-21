pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                // Checkout code from Git
                git 'https://github.com/NirmalNaveen20/supermario-k8s.git'
                // Build Docker image
                sh 'docker build -t nirmalnaveen/supermario .'
            }
        }
        stage('Test') {
            steps {
                // Run tests if any
                // Add test commands here
            }
        }
        stage('Deploy') {
            steps {
                // Deploy to Kubernetes
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
            }
        }
    }
}
