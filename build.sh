#!/bin/bash

function find_tag(){
    if [[ $search == "latest" ]]; then
        echo $(echo $releases | jq ".[] | select(.prerelease == false) | .tag_name" -r | head -n1)
    elif [[ $search == "latest-pre" ]]; then
        echo $(echo $releases | jq ".[0].tag_name" -r)
    else
        echo $(echo $releases | jq ".[] | select(.tag_name == \"$search\") | .tag_name" -r)
    fi
}

function find_url(){
    if [[ $search == "latest" ]]; then
        echo $(echo $releases | jq ".[] | select(.prerelease == false) | .url" -r | head -n1)
    elif [[ $search == "latest-pre" ]]; then
        echo $(echo $releases | jq ".[0].url" -r)
    else
        echo $(echo $releases | jq ".[] | select(.tag_name == \"$search\") | .url" -r)
    fi
}

function validate(){
    count=$(echo $tag | wc -c)
    if [ $count -le 2 ]; then
        echo >&2 "Tag '$search' could not be found"
        usage
    fi

    count=$(echo $url | wc -c)
    if [ $count -le 2 ]; then
        echo >&2 "URL for '$search' could not be found. This error is not supposed to happen c:"
        usage
    fi
}

function login(){
    host=$(echo $GIT_PUSH_IMAGE | cut -d/ -f1)
    result=$(docker login -u $GIT_PUSH_USER -p $GIT_PUSH_TOKEN $host 2>&1 | grep "Access denied" | wc -l)
    if [ $result -gt 0 ]; then
        echo >&2 "Docker registry login failed."
        usage
    fi
}

function build(){
    count=$(docker images | grep "${GIT_PUSH_IMAGE}" | grep "$tag" | wc -l)
    if [ $count -gt 0 ]; then
        echo "Tag '$tag' already built. Skipping build process."
        return 1
    fi

    cat Dockerfile.base | sed "s/\$VERSION/$tag/g" | sed "s,\$URL,$url,g" > Dockerfile
    docker build -t $GIT_PUSH_IMAGE:$tag .
    rm Dockerfile

    if [ $search == "latest" ]; then
        docker tag $GIT_PUSH_IMAGE:$tag $GIT_PUSH_IMAGE:latest
    elif [ $search == "latest-pre" ]; then
        docker tag $GIT_PUSH_IMAGE:$tag $GIT_PUSH_IMAGE:latest-pre
    fi
}

function push(){
    docker push $GIT_PUSH_IMAGE:$tag
    if [ $search == "latest" ]; then
        docker push $GIT_PUSH_IMAGE:latest
    elif [ $search == "latest-pre" ]; then
        docker push $GIT_PUSH_IMAGE:latest-pre
    fi
}

function usage(){
    echo "Usage: GIT_PUSH_TOKEN=abcdef sudo bash build.sh [OPTION]... [TAG]"
    echo "This script pulls and builds the latest velociraptor version locally."
    echo "If all three push options are set, it tags the built images accordingly and pushes them to set container registry."
    echo ""
    echo "Supported TAGs:"
    echo "  - latest ... pulls latest stable version - default"
    echo "  - latest-pre ... pulls latest version including prereleases"
    echo "  - v0.6.5-0 ... all tags used in the repo url /releases/tag/<tag_name>"
    echo ""
    echo "Supported OPTIONs:"
    echo "  -h, --help          display this help and exit"
    echo "  -u, --push-user     username for container registry"
    echo "  -t, --push-token    push token for container registry"
    echo "  -i, --push-image    URI to container registry (e.g. git.local:123/repo/image)"
    exit 0
}

function root(){
    if [ 0 -ge $(id | grep root | wc -l) ]; then
        echo >&2 "Script was not run as root. Exiting."
        exit 1
    fi
}


# Set default values
releases=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases)
search=latest
GIT_PUSH_IMAGE=velociraptor # default name of local builds

# read parameters
TEMP=`getopt -o ht:u:i: --long help,push-token:,push-user:,push-image: -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -t|--push-token)
            shift
            GIT_PUSH_TOKEN=$1
            shift
            ;;
        -u|--push-user)
            shift
            GIT_PUSH_USER=$1
            shift
            ;;
        -i|--push-image)
            shift
            GIT_PUSH_IMAGE=$1
            shift
            ;;
        --) 
            shift
            search=${1:-latest}
            shift
            ;;
        *)
            break
            ;;
    esac
done

# run script
root
url=$(find_url)
tag=$(find_tag)
validate
build

skip=0
if [[ $GIT_PUSH_TOKEN == "" ]]; then >&2 echo "Push token not specified."; skip=1; fi
if [[ $GIT_PUSH_USER  == "" ]]; then >&2 echo "Push user not specified."; skip=1; fi
if [[ $GIT_PUSH_IMAGE == "" ]]; then >&2 echo "Push image not specified."; skip=1; fi
if [ $skip = 1 ]; then >&2 echo "Skipping push."; exit 0; fi

login
push
