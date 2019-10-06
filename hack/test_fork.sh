#!/bin/bash

set -eo pipefail

GITLAB_URL="https://gitlab.cee.redhat.com"
GITLAB_API="$GITLAB_URL/api/v4"
GITLAB_PROJECTS_URL="$GITLAB_API/projects"

if [[ "$gitlabSourceBranch" == "master" ]]; then
    NOTE="@$gitlabSourceNamespace, this merge request is using the 'master' source branch. Please submit a new merge request from another branch."
    URL_NOTE=$(echo $NOTE | sed -e "s| |%20|g" -e "s|!|%0A|g" -e "s|'|%60|g" -e "s|\[|%5B|g" -e "s|\]|%5D|g" -e "s|(|%28|g" -e "s|)|%29|g" -e "s|#|%23|g" -e "s|@|%40|g" -e "s|,|%2C|g")
    curl -s --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid/notes?body=$URL_NOTE > /dev/null
    exit 1
fi

BLOCKED_LABEL="blocked/devtools-bot-access"
GITLAB_GROUPS_URL="$GITLAB_API/groups"
SOURCE_PROJECT_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid | jq .source_project_id)
PROJECT_MEMBERS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$SOURCE_PROJECT_ID/members)
MEMBER_IDS=$(echo $PROJECT_MEMBERS | jq -c '.[] | .id')

BOT_ID=3889
BOT_ACCESS_LEVEL=$(echo $PROJECT_MEMBERS | jq -c ".[] | select(.id == $BOT_ID) | .access_level")
# check if bot is a maintainer on the fork
exit_status=0
# check if bot is a maintainer on the fork
if [[ "$BOT_ACCESS_LEVEL" != "40" ]]; then
    exit_status=1
fi

# if bot is not a maintainer on the fork - add error note on merge request and exit
if [[ "$exit_status" != "0" ]]; then

    # '!' stands for new line
    NOTE="@$gitlabSourceNamespace, this fork of 'app-interface' is not shared with [devtools-bot]($GITLAB_URL/devtools-bot) as 'Maintainer'.!!Please [add the user to the project]($gitlabSourceRepoHomepage/project_members) and retest by commenting '[test]' on the merge request."
    URL_NOTE=$(echo $NOTE | sed -e "s| |%20|g" -e "s|!|%0A|g" -e "s|'|%60|g" -e "s|\[|%5B|g" -e "s|\]|%5D|g" -e "s|(|%28|g" -e "s|)|%29|g" -e "s|#|%23|g" -e "s|@|%40|g" -e "s|,|%2C|g")
    curl -s --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid/notes?body=$URL_NOTE > /dev/null

    # add blocked label on the merge request
    LABELS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid | jq -r .labels[])
    NEW_LABELS=""
    for l in $LABELS; do NEW_LABELS="${NEW_LABELS}${NEW_LABELS:+,}$l"; done
    NEW_LABELS="${NEW_LABELS}${NEW_LABELS:+,}$BLOCKED_LABEL"
    curl -s --request PUT --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid?labels=$NEW_LABELS > /dev/null
    exit $exit_status
fi

# Add app-sre gitlab group members to fork
APP_SRE_GROUP_ID=6887
USER_IDS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_GROUPS_URL/$APP_SRE_GROUP_ID/members | jq -c '.[] | .id')
for USER_ID in $USER_IDS; do
    FOUND=false
    for MEMBER_ID in $MEMBER_IDS; do
        if [[ "$MEMBER_ID" != "$USER_ID" ]]; then
            continue
        fi
        FOUND=true
        break
    done
    if [[ "$FOUND" == "true" ]]; then
        continue
    fi
    curl -s --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --data "user_id=$USER_ID&access_level=40" $GITLAB_PROJECTS_URL/$SOURCE_PROJECT_ID/members > /dev/null
done

# remove blocked label from the merge request
LABELS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid | jq -r .labels[])
NEW_LABELS=""
for l in $LABELS; do if [[ "$l" != "$BLOCKED_LABEL" ]]; then NEW_LABELS="${NEW_LABELS}${NEW_LABELS:+,}$l"; fi; done
curl -s --request PUT --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid?labels=$NEW_LABELS > /dev/null
