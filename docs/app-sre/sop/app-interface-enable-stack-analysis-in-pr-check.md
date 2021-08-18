# Enable Stack Analysis in PR check jobs in Jenkins

To enable Stack Analysis in PR check jobs in Jenkins, add the following key to the job definition:
```yml
run_stack_analysis_path: 'true'
```

This will enable the following section in the job: https://gitlab.cee.redhat.com/service/app-interface/-/blob/307dbca28b12c883704e7b6024f9a5929410728f/resources/jenkins/global/base-templates.yaml#L57-64
