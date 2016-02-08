#!/bin/bash
# In addition to deploying the site to Multidev, we also want the wraith visual to be accessible
# Normalize the mutldiev environment URL based on branch name
if [ "$CIRCLE_BRANCH" != "master" ] && [ "$CIRCLE_BRANCH" != "dev" ] && [ "$CIRCLE_BRANCH" != "test" ] && [ "$CIRCLE_BRANCH" != "live" ] && ! [[ $CIRCLE_BRANCH =~ (pull\/.*) ]]; then
    # Normalize branch name to adhere with Multidev requirements
    export normalize_branch="$CIRCLE_BRANCH"
    export valid="^[-0-9a-z]" # allows digits 0-9, lower case a-z, and -
    if [[ $normalize_branch =~ $valid ]]; then
        export normalize_branch="${normalize_branch:0:11}"
        #Remove - to avoid failures
        export normalize_branch="${normalize_branch//-}"
        echo "Success: "$normalize_branch" is a valid branch name."
    else
        echo "Error: Multidev cannot be created due to invalid branch name: $normalize_branch"
        exit 1
    fi

    # rename gallery to index
    mv shots/gallery.html shots/index.html
    # rsync gallery diff from wraith to Valhalla
    rsync --size-only --checksum --delete-after -rtlvz --ipv4 --progress -e 'ssh -p 2222' shots/* --temp-dir=../../../tmp/ $normalize_branch.$STATIC_DOCS_UUID@appserver.$normalize_branch.$STATIC_DOCS_UUID.drush.in:files/docs/shots/
    if [ "$?" -eq "0" ]
    then
        echo "Success: Deployed to http://"$normalize_branch"-static-docs.pantheon.io/docs"
    else
        echo "Error: Deploy failed, review rsync status"
        exit 1
    fi

    # Clear cache on multidev env
    ~/documentation/bin/terminus site clear-cache --site=static-docs --env=$normalize_branch
fi
