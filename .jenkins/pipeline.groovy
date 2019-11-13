pipeline {
  agent {
    label 'docker'
  }
  
  environment {
    project_name = "demo"
    project_owner = "ruan"
    slack_channel = "system_events"
    AWS_REGION = "eu-west-1"
    AWS_DEV_ACCOUNT_NUMBER = credentials('AWS_DEV_ACCOUNT_NUMBER')
    AWS_ACCESS_KEY = credentials('AWS_MASTER_JENKINS_AK')
    AWS_SECRET_KEY = credentials('AWS_MASTER_JENKINS_SK')
    AWS_CROSS_ACCOUNT_ROLE_ARN = "arn:aws:iam::$AWS_DEV_ACCOUNT_NUMBER:role/SystemCrossAccountAccess"
    GIT_TOKEN = credentials('GITHUB_TOKEN')
    SLACK_TOKEN_SECRET = credentials('SLACK_TOKEN_SECRET')
  }
  
  stages{
    stage('BuildDeploymentPackage') {
      steps {
        script {
          docker.image('lambci/lambda:build-python3.7').inside('--privileged --user root -e AWS_REGION="eu-west-1"'){
            sh '''source bin/setup_aws_environment.sh
                  echo "START [package-step]: start of packaging function"
                  bash ../bin/package_function.sh
                  echo "END [package-step]: packaging function completed
               '''
          }
        }
      }
      
      post {
        always {
          script {
            sh '''echo "foo"'''
          }
        }
        success {
          slackSend(channel: "${env.slack_channel}", message: "\n:white_check_mark: *${env.STAGE_NAME} passed*\n\n    Job URL: ${env.JOB_URL}${env.BUILD_NUMBER}\n    PR: ${env.GITHUB_PR_URL}\n", iconEmoji: "jenkins", username: "Jenkins")
        }
        failure {
          slackSend(channel: "${env.slack_channel}", message: "\n:red_circle: *${env.STAGE_NAME} ran into testing issues, probably best to check it out*\n\n    PR: ${env.GITHUB_PR_URL}\n", iconEmoji: "jenkins", username: "Jenkins")
        }
      }
    }
    stage('ShipToS3') {
      steps {
        script {
          docker.image('lambci/lambda:build-python3.7').inside('--privileged --user root -e AWS_REGION="eu-west-1"'){
            sh '''source bin/setup_aws_environment.sh
                  echo "shipping"
               '''
          }
        }
      }
      
      post {
        always {
          script {
            sh '''echo "foo"'''
          }
        }
        success {
          slackSend(channel: "${env.slack_channel}", message: "\n:white_check_mark: *${env.STAGE_NAME} passed*\n\n    Job URL: ${env.JOB_URL}${env.BUILD_NUMBER}\n    PR: ${env.GITHUB_PR_URL}\n", iconEmoji: "jenkins", username: "Jenkins")
        }
        failure {
          slackSend(channel: "${env.slack_channel}", message: "\n:red_circle: *${env.STAGE_NAME} ran into testing issues, probably best to check it out*\n\n    PR: ${env.GITHUB_PR_URL}\n", iconEmoji: "jenkins", username: "Jenkins")
        }
      }
    }
    
    stage('DeployToProd') {        
      steps{
        script {          
          sh '''source bin/setup_aws_environment.sh
                mkdir -p /tmp
                bash bin/deploy_dummy.sh prod '''
        }
      }
      
      post {
        always {
          script {
            sh '''echo "foo"'''
          }
        }
      }
    }
  }
}
