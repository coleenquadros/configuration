# Checking the Basic Health of Compliance

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
The Insights Compliance service enables IT security and compliance administrators to assess, monitor, and report on the security-policy compliance of RHEL systems. The compliance service provides a simple but powerful user interface, enabling the creation, configuration, and management of SCAP security policies. If Compliance is broken, customers aren't being able to use these functions.

## Summary
This document is information on checking the overall of Compliance. 

## Prerequisite
In order to follow the next set of instructions, you will need a system that is already registered with Red Hat Insights. If you do not have one, follow [these instructions](https://console.redhat.com/insights/registration?extIdCarryOver=true&sc_cid=701f2000001Css5AAC) to register a system

## Compliance Basic Health Check

1. Go to [Compliance page on consoledot](https://console.redhat.com/insights/compliance). If you're not logged in you will be prompted to log in. This link should take you to the Compliance Reports page. 
2. On the Reports page, you should see a message saying "No policies are reporting" if you have no reports. If you do have reports, you will see them listed on the Reports table. 
3. If you have at least one report, you should be able to click on the report and it will take you to a page with the details of the report. If you do not have a report, go to step 4. 
4. Verify that the SCAP Policies tab is working correctly by clicking "SCAP Policies" on the left navigation panel. If you have no policies, you should see a message saying "No policies". If you do have policies, you should see a list of your current SCAP policies in the SCAP policies table.
5. If you have at least one SCAP policy available, click on one to make sure you can view the Policy Details successfully. If you do not have a SCAP policy, go to step 6. 
6. On the SCAP Policies tab, click "Create new policy" button.
7. You should see the Create SCAP policy modal pop up. Click on the RHEL version that you have a system registered with and then select the policy type. Click next and edit the details page however you want. Click next again and you should see your system that you have registered in the list of Systems. Select your system and click Next. Update the Rules page however you would like and then click Next. Review the new polcy and click Finish.
8. Verify on the SCAP Policy table that your new policy is there.
9. Click on the policy and then click on the Systems tab on the Policy details page and verify that your system is there.
10. Click on the Systems tab on the left navigation panel under Compliance and verify that your system is there with the correct policy or policies associated with it. 
11. Go to your terminal, on the system that you have registered(that you just added a policy to), and run the command `insights-client --compliance` to generate a report for your policy or policies associated with your system. Note: Make sure that your system is registered to `insights-client`. If you have not done this, follow the prerequisite instructions above.
12. Go back to your browser and click the Reports tab on the left navigation panel under the Compliance section. Verify that your new report is there(it may take a couple minutes to appear). Click on the report and verify that you can see your Report details. 


## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/compliance/app.yml
