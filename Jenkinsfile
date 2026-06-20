pipeline {
  agent any

  environment {
    NODE_OPTIONS = "--max_old_space_size=4096"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install Dependencies') {
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
          if (isUnix()) {
            sh 'npm run lint'
          } else {
            bat 'npm run lint'
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
    }

    stage('Migrate DB') {
      when {
        expression { return params.RUN_DB_MIGRATIONS == true }
      }
      steps {
        script {
          if (isUnix()) {
            sh 'npm run db:migrate'
          } else {
            bat 'npm run db:migrate'
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'coverage/**', allowEmptyArchive: true
    }
    success {
      echo 'AppointmentService pipeline completed successfully.'
    }
    failure {
      echo 'AppointmentService pipeline failed. Check the logs for details.'
    }
  }
}
