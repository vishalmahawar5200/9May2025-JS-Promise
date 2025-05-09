pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "vishalmahawar5200/9may2025"
        DEPLOY_USER = "root"
        DEPLOY_HOST = "65.108.149.166"
    }

    stages {
        stage('Install Docker dependencies') {
            steps {
                sh '''
                    apt update
                    apt upgrade -y
                    apt install -y docker.io
                '''
            }
        }

        stage('Start Docker Daemon (if not running)') {
            steps {
                sh '''
                    if ! pgrep dockerd > /dev/null; then
                        echo "Starting Docker Daemon"
                        nohup dockerd > /tmp/dockerd.log 2>&1 &
                        sleep 10
                    else
                        echo "Docker daemon is already running"
                    fi
                '''
            }
        }

        stage('Check Version') {
            steps {
                sh "docker --version"
            }
        }

        stage('Build Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'docker build -t ${DOCKER_IMAGE}:t1 .'
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        def imageTag = "v${env.BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE}:t1 ${DOCKER_IMAGE}:${imageTag}"
                        sh "docker push ${DOCKER_IMAGE}:${imageTag}"
                    }
                }
            }
        }

        stage('Deploy to Another Server'){
            steps{
                sshagent (credentials: ['ID_RSA']) {
                    script{
                        def imageTag = "v${env.BUILD_NUMBER}"
                        sh """
                            hostname && hostname -I
                            ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST '
                            hostname && hostname -I
                            docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq)
                            docker pull ${DOCKER_IMAGE}:${imageTag}
                           docker run -d -p 8032:80 ${DOCKER_IMAGE}:${imageTag} /usr/sbin/apache2ctl -D FOREGROUND
                        '
                        hostname && hostname -I
                        """
                    }
                }
            }
        }
    }
}