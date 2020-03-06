---
$schema: /app-interface/app-interface-email-1.yml
labels: {}
name: 2020-03-06-ci-int-degradation
subject: '[app-sre] ci-int partial degradation'
to:
    aliases:
    - all-service-owners
body: |
    Hello,

    We are experiencing a ci-int partial degradation following a hardware failure on the central-ci storage infrastructure.
    
    Jenkins jobs are failing to complete , timing out and stuck in queue. There is not much we can do at this time.
    
    Updates will be posted on the thread in #sd-org 
    
    You can follow the upstream incident here https://one.redhat.com/outages/list/details/5e626c53fe9e68efb145577c

    The AppSRE Team.
