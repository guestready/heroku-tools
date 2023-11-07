#!/usr/bin/env bash

function exit_with_usage_error {
    >&2 echo "USAGE: $program_path [heroku_app_name]"
    >&2 echo "  Check the status of the latest release of an Heroku app"

    exit 1
}

function does_not_contain {
    echo "$1" | grep --invert-match --quiet --null-data "$2"
}

function get_release_status {
    while :
    do
        release_status=$(heroku releases --app "$app_name" --num 1)

        does_not_contain "$release_status" "$release_in_progress_match"
        if (( $? == 0 )) ; then
            echo "$release_status"
            return
        else
            sleep 1
        fi
    done
}

function main {
    readonly program_path="$0"

    readonly argc="$#"
    if [ "$argc" -ne 1 ] ; then
        exit_with_usage_error
    fi
    readonly app_name=$1

    readonly release_failed_match='failed'
    readonly release_in_progress_match='executing'

    does_not_contain "$(get_release_status)" "$release_failed_match"
    if (( $? == 0 )) ; then
        echo 'Heroku release successful!'
        exit 0
    else
        echo 'Heroku release failed!'
        echo 'The release tasks have probably failed.'
        echo 'Check the Heroku deploy step above for more details.'
        exit 1
    fi
}

main "$@"
