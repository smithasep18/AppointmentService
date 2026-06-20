pipeline {
  agent any

  options {
    skipDefaultCheckout()
  }

  environment {
    APP_NAME = 'appointment-service'
  }

  parameters {
    string(name: 'REPO_URL', defaultValue: 'https://github.com/smithasep18/AppointmentService.git', description: 'Git repository URL to clone')
    string(name: 'BRANCH', defaultValue: 'main', description: 'Branch name to clone')
    string(name: 'ECR_REGISTRY', defaultValue: '', description: 'ECR registry URI, e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com')
    string(name: 'IMAGE_TAG', defaultValue: "${env.BUILD_NUMBER}", description: 'Docker image tag')
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region for ECR')
    string(name: 'AWS_CREDENTIALS_ID', defaultValue: '', description: 'Jenkins AWS credentials ID')
  }

  stages {
    stage('Checkout') {
      steps {
        script {
          if (!params.REPO_URL?.trim()) {
            error 'REPO_URL is required for checkout.'
          }

          cleanWs()
          dir('source') {
            git branch: params.BRANCH, url: params.REPO_URL
          }
        }
      }
    }

    stage('Build') {
      steps {
        script {
          def imageName = "${params.ECR_REGISTRY}/${env.APP_NAME}:${params.IMAGE_TAG}"
          dir('source') {
            sh "docker build -t ${imageName} ."
          }
        }
      }
    }

    stage('Push') {
      steps {
        script {
          if (!params.ECR_REGISTRY?.trim()) {
            error 'ECR_REGISTRY is required to push the image.'
          }
          if (!params.AWS_CREDENTIALS_ID?.trim()) {
            error 'AWS_CREDENTIALS_ID is required for ECR login.'
          }

          def ecrHost = params.ECR_REGISTRY.split('/')[0]
          def imageName = "${params.ECR_REGISTRY}/${env.APP_NAME}:${params.IMAGE_TAG}"

          withCredentials([usernamePassword(credentialsId: params.AWS_CREDENTIALS_ID, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh "aws ecr get-login-password --region ${params.AWS_REGION} | docker login --username AWS --password-stdin ${ecrHost}"
            sh "docker push ${imageName}"
          }
        }
      }
    }
  }

  post {
    success {
      echo "Docker image pushed: ${params.ECR_REGISTRY}/${env.APP_NAME}:${params.IMAGE_TAG}"
    }
    failure {
      echo 'Pipeline failed; please check the Jenkins console output.'
    }
  }
}
