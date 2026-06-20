pipeline {
  agent any

  parameters {
    string(name: 'IMAGE_TAG', defaultValue: "${env.BUILD_NUMBER}", description: 'Tag for Docker image')
    string(name: 'DOCKER_REGISTRY', defaultValue: '', description: 'Optional: registry host (e.g. myregistry.example.com/repo)')
    string(name: 'DOCKER_CREDENTIALS_ID', defaultValue: '', description: 'Jenkins credentials ID for Docker registry (username/password)')
    booleanParam(name: 'RUN_DB_MIGRATIONS', defaultValue: false, description: 'Run DB migrations after build')
  }

  environment {
    NODE_OPTIONS = "--max_old_space_size=4096"
    APP_NAME = 'appointment-service'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install') {
      steps {
        script {
          if (isUnix()) {
            sh 'npm ci'
          } else {
            bat 'npm ci'
          }
        }
      }
    }

    stage('Lint') {
      steps {
        script {
          if (fileExists('package.json')) {
            if (isUnix()) {
              sh 'npm run lint || true'
            } else {
              bat 'npm run lint || exit 0'
            }
          } else {
            echo 'No package.json found; skipping lint.'
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          if (isUnix()) {
            sh 'npm test'
          } else {
            bat 'npm test'
          }
        }
      }
      post {
        always {
          archiveArtifacts artifacts: 'coverage/**', allowEmptyArchive: true
        }
      }
    }

    stage('Build') {
      steps {
        script {
          if (fileExists('package.json')) {
            if (isUnix()) {
              sh 'npm run build || true'
            } else {
              bat 'npm run build || exit 0'
            }
          } else {
            echo 'No package.json found; skipping build.'
          }
        }
      }
    }

    stage('Docker Build & Push') {
      when {
        expression { return params.DOCKER_REGISTRY?.trim() }
      }
      steps {
        script {
          def registry = params.DOCKER_REGISTRY.trim()
          def image = "${registry}/${env.APP_NAME}:${params.IMAGE_TAG}"

          if (!params.DOCKER_CREDENTIALS_ID?.trim()) {
            error 'DOCKER_CREDENTIALS_ID is required to push images'
          }

          withCredentials([usernamePassword(credentialsId: params.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh "echo $DOCKER_PASS | docker login ${registry.split('/')[0]} -u $DOCKER_USER --password-stdin"
            sh "docker build -t ${image} ."
            sh "docker push ${image}"
            sh "docker logout ${registry.split('/')[0]}"
          }
        }
      }
    }

    stage('Migrate DB') {
      when {
        expression { return params.RUN_DB_MIGRATIONS == true }
      }
      steps {
        script {
          if (isUnix()) {
            sh 'npm run db:migrate || true'
          } else {
            bat 'npm run db:migrate || exit 0'
          }
        }
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'test-results/**/*.xml'
      archiveArtifacts artifacts: 'dist/**,coverage/**', allowEmptyArchive: true
      cleanWs()
    }
    success {
      echo 'AppointmentService pipeline completed successfully.'
    }
    failure {
      echo 'AppointmentService pipeline failed. Inspect the console output.'
    }
  }
}
