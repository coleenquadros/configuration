#!/bin/bash

set -eo pipefail

GITLAB_URL="https://gitlab.cee.redhat.com"
GITLAB_PROJECTS_URL="$GITLAB_URL/api/v4/projects"
SOURCE_PROJECT_ID=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid | jq .source_project_id)
SHARED_WITH_GROUPS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$SOURCE_PROJECT_ID | jq .shared_with_groups)

APP_SRE_GROUP_ID=6887
exit_status=1
for g in $(echo $SHARED_WITH_GROUPS | jq -c .[]); do
    GROUP_ID=$(echo $g | jq .group_id)
    if [[ "$GROUP_ID" != "$APP_SRE_GROUP_ID" ]]; then
        continue
    fi
    GROUP_ACCESS_LEVEL=$(echo $g | jq .group_access_level)
    if [[ "$GROUP_ACCESS_LEVEL" == "40" ]]; then
        exit_status=0
    fi
    break
done

if [[ "$exit_status" != "0" ]]; then
    # '!' stands for new line
    NOTE="@$gitlabSourceNamespace, This fork of 'app-interface' is not shared with the [app-sre]($GITLAB_URL/app-sre) group as 'Master'.!!Please [share the project with the group](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html#sharing-a-project-with-a-group-of-users) and retest by commenting '[test]' on the merge request."
    URL_NOTE=$(echo $NOTE | sed -e "s| |%20|g" -e "s|!|%0A|g" -e "s|'|%60|g" -e "s|\[|%5B|g" -e "s|\]|%5D|g" -e "s|(|%28|g" -e "s|)|%29|g" -e "s|#|%23|g" -e "s|@|%40|g" -e "s|,|%2C|g")
    curl -s --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" $GITLAB_PROJECTS_URL/$gitlabMergeRequestTargetProjectId/merge_requests/$gitlabMergeRequestIid/notes?body=$URL_NOTE
fi

exit $exit_status
