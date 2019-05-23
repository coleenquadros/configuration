#!/bin/bash

set -eo pipefail

GITLAB_URL="https://gitlab.cee.redhat.com"
GITLAB_API="$GITLAB_URL/api/v4"
GITLAB_PROJECTS_URL="$GITLAB_API/projects"
SOURCE_PROJECT_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid | jq .source_project_id)
PROJECT_MEMBERS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$SOURCE_PROJECT_ID/members)
BLOCKED_LABEL="blocked/devtools-bot-access"

APP_SRE_BOT_ID=3889

# check if bot is a maintainer on the fork
exit_status=1
MEMBER_IDS=$(echo $PROJECT_MEMBERS | jq -c '.[] | .id')
for MEMBER_ID in $MEMBER_IDS; do
    if [[ "$MEMBER_ID" != "$APP_SRE_BOT_ID" ]]; then
        continue
    fi
    MEMBER_ACCESS_LEVEL=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$SOURCE_PROJECT_ID/members/$MEMBER_ID | jq .access_level)
    if [[ "$MEMBER_ACCESS_LEVEL" == "40" ]]; then
        exit_status=0
    fi
    break
done

# if bot is not a maintainer on the fork - add error note on merge request and exit
if [[ "$exit_status" != "0" ]]; then

    # '!' stands for new line
    NOTE="@$gitlabSourceNamespace, this fork of 'app-interface' is not shared with [devtools-bot]($GITLAB_URL/devtools-bot) as 'Maintainer'.!!Please [add the user to the project](https://docs.gitlab.com/ee/user/project/members/#add-a-user) and retest by commenting '[test]' on the merge request."
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

# Add app-sre team to fork
USERS=$(ls data/teams/app-sre/users | sed 's/.yml//g')
for u in $USERS; do
    USER_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_API/users?username=$u | jq '.[] | .id')
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
