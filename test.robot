*** Variables ***

${HOSTNAME}             127.0.0.1
${PORT}                 8080
${SERVER}               http://${HOSTNAME}:${PORT}
${BROWSER}              chrome


*** Settings ***

Documentation   Jenkins Pipeline Job Acceptance Test
Library         SeleniumLibrary  timeout=30  implicit_wait=0
# Library         DebugLibrary
Library         OperatingSystem
Library         XML
Test Setup      Test Setup
Test Teardown   Close Browser


*** Test Cases ***

Scenario: Jenkins is up and running
  Go to  ${SERVER}
  Wait until page contains  Jenkins
  Page Should Contain  Jenkins
  # Wait until page contains element  css=#header
  Page should not contain  log in
  # Wait until page contains element  css=#tasks
  # ${html}=  Get source
  # Log  ${html}  WARN
  Wait until page contains element  xpath=//a[@href='/manage']
  Page should contain element  xpath=//a[@href='/manage']

# Scenario: Install Jenkins Plugins
#   Go to  ${SERVER}/pluginManager/available
#   Wait until page contains element  xpath=//input[@name='plugin.github.default']
#   Wait until element is visible  xpath=//input[@name='plugin.github.default']
#  Select checkbox  plugin.github.default
#  Select checkbox  plugin.workflow-aggregator.default
#  Click button  css=#yui-gen1-button
#  Wait until page contains element  css=#scheduleRestart
#  Select checkbox  css=#scheduleRestartCheckbox

Scenario: Pipeline job is present
  Go To  ${SERVER}/view/All/newJob
  Wait until page contains element  css=#name
  Wait until page contains  Pipeline
  Page should contain  Pipeline
  Page should contain  Suitable for building pipelines
  # Input Text  css=#name  Pipeline
  # Click Element  css=.org_jenkinsci_plugins_workflow_job_WorkflowJob
  # Click button  OK
  # Debug

Scenario: Test Pipeline
  Set up pipeline
  Go to  ${SERVER}/job/pipeline/build?delay=0sec
  Go to  ${SERVER}/job/pipeline
  Wait until page contains  1
  Sleep  30
  Go to  ${SERVER}/job/pipeline/1
  Wait until page contains  Build #1
  ${html}=  Get source
  Log  ${html}  WARN
  Wait until page does not contain element  xpath=//*[@tooltip="In progress"]  timeout=60
  Wait until page contains element  css=.icon-blue
  Page should contain element  css=.icon-blue

*** Keywords ***

Test Setup
  Open Browser  ${SERVER}  ${BROWSER}
  Set Window Size  1024  768

Set up Pipeline
  Run  wget http://localhost:8080/jnlpJars/jenkins-cli.jar -nc -O jenkins-cli.jar
  Run  java -jar jenkins-cli.jar -s http://localhost:8080 create-job pipeline < pipeline.xml
  ${Jenkinsfile}=  Get File  Jenkinsfile
  ${XML}=	Parse XML	 pipeline.xml
  # Clear Element  ${XML}  xpath=//script
  Set Element Text  ${XML}  text=${Jenkinsfile}  xpath=definition/script
  ${script}=  Get element text  ${XML}  xpath=definition/script
  Log  ${script}  WARN