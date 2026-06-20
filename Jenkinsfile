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
    string(name: 'DOCKER_REGISTRY', defaultValue: 'smitha18/appointmentservice', description: 'Docker Hub repository name (e.g. smitha18/appointmentservice)')
    string(name: 'IMAGE_TAG', defaultValue: "${env.BUILD_NUMBER}", description: 'Docker image tag')
    string(name: 'DOCKER_CREDENTIALS_ID', defaultValue: 'docker-hub', description: 'Jenkins credentials ID for Docker Hub login')
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
            echo "Cloning repository ${params.REPO_URL} branch ${params.BRANCH}"
            checkout([
              $class: 'GitSCM',
              branches: [[name: params.BRANCH]],
              userRemoteConfigs: [[url: params.REPO_URL]]
            ])
          }
        }
      }
    }

    stage('Build') {
      steps {
        script {
          if (!params.DOCKER_REGISTRY?.trim()) {
            error 'DOCKER_REGISTRY is required to build the image. Set the Docker Hub repository before running the pipeline.'
          }
          def imageName = "${params.DOCKER_REGISTRY}:${params.IMAGE_TAG}"
          dir('source') {
            sh "docker build -t ${imageName} ."
          }
        }
      }
    }

    stage('Push') {
      steps {
        script {
          if (!params.DOCKER_REGISTRY?.trim()) {
            error 'DOCKER_REGISTRY is required to push the image.'
          }
          if (!params.DOCKER_CREDENTIALS_ID?.trim()) {
            error 'DOCKER_CREDENTIALS_ID is required for Docker Hub login.'
          }

          def imageName = "${params.DOCKER_REGISTRY}:${params.IMAGE_TAG}"

          withCredentials([usernamePassword(credentialsId: params.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh "echo $DOCKER_PASS | docker login --username $DOCKER_USER --password-stdin"
            sh "docker push ${imageName}"
            sh "docker logout"
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
