#!/usr/bin/env groovy

pipeline {
  agent any

  options {
    ansiColor('xterm')
    timestamps()
  }

  libraries {
    lib("pay-jenkins-library@master")
  }

  stages {
    // stage('Test') {
    //  steps {
    //    sh './ci-build.sh'
    //  }
    //}

    stage('Docker Build') {
      steps {
        script {
          buildAppWithMetrics{
            app = "notifications"
          }
        }
      }
      post {
        failure {
          postMetric("notifications.docker-build.failure", 1)
        }
      }
    }

    stage('Docker Tag') {
      steps {
        script {
          dockerTagWithMetrics {
            app = "notifications"
          }
        }
      }
      post {
        failure {
          postMetric("notifications.docker-tag.failure", 1)
        }
      }
    }
    stage('Complete') {
      failFast true
      parallel {
        stage('Tag Build') {
          when {
            branch 'master'
          }
          steps {
            tagDeployment("notifications")
          }
        }
      }
    }
  }
  post {
    failure {
      postMetric(appendBranchSuffix("notifications") + ".failure", 1)
    }
    success {
      postSuccessfulMetrics(appendBranchSuffix("notifications"))
    }
  }
}
