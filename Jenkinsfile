pipeline {
    agent {
      node{
	    label "SLAVE-1"
	    customWorkspace 'workspace/' + env.JOB_NAME
	  } 
    }

    stages {
        
        stage('GitCheckout') {
            steps {
            
               git branch: 'main',
               url: 'https://github.com/abila98/JSP_APP.git'
            }
        }
         stage('Ant Build') {
            steps {
            sh '''
				    ant -f application/build.xml war
				'''
            }
        }
        
        stage('Deploy War') {
            steps {
            sh '''
				    ansible-playbook ansible/application.yml -i ansible/inventory_application
				'''
            }
        }
    }
    
    
    
        post {
        always{

            cleanWs()
            dir("${env.WORKSPACE}@tmp") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script@tmp") {
                deleteDir()
            }
        }
	} 
}
