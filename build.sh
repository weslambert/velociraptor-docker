#!/bin/bash

search=${1:-latest}
releases=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases)
GIT_PUSH_HOST=git.local:1234
GIT_PUSH_IMAGE=${git_dst_host}/user/velo
GIT_PUSH_USER=username

function find_tag(){
    if [ $search == "latest" ]; then
        echo $(echo $releases | jq ".[] | select(.prerelease == false) | .tag_name" -r | head -n1)
    elif [ $search == "latest-pre" ]; then
        echo $(echo $releases | jq ".[0].tag_name" -r)
    else
        echo $(echo $releases | jq ".[] | select(.tag_name == \"$search\") | .tag_name" -r)
    fi
}

function find_url(){
    if [ $search == "latest" ]; then
        echo $(echo $releases | jq ".[] | select(.prerelease == false) | .url" -r | head -n1)
    elif [ $search == "latest-pre" ]; then
        echo $(echo $releases | jq ".[0].url" -r)
    else
        echo $(echo $releases | jq ".[] | select(.tag_name == \"$search\") | .url" -r)
    fi
}

function validate(){
    count=$(echo $tag | wc -c)
    if [ $count -le 2 ]; then
        echo "Tag '$search' could not be found"
        usage
    fi

    count=$(echo $url | wc -c)
    if [ $count -le 2 ]; then
        echo "URL for '$search' could not be found. This error is not supposed to happen c:"
        usage
    fi
}

function login(){
    result=$(docker login -u $GIT_PUSH_USER -p $GIT_PUSH_TOKEN $GIT_PUSH_HOST 2>&1 | grep "Access denied" | wc -l)
    if [ $result -gt 0 ]; then
        echo "Docker registry login failed."
        usage
    fi
}

function build(){
    count=$(docker images | grep "/velo" | grep "$tag" | wc -l)
    if [ $count -gt 0 ]; then
        echo "Tag '$tag' already built. Skipping build process."
        return 1
    fi

    cat Dockerfile.base | sed "s/\$VERSION/$tag/g" | sed "s,\$URL,$url,g" > Dockerfile
    docker build -t $git_dst_repo:$tag .
    rm Dockerfile
}

function push(){
    docker push $git_dst_repo:$tag
    if [ $search == "latest" ]; then
        docker tag $git_dst_repo:$tag $git_dst_repo:latest
        docker push $git_dst_repo:latest
    elif [ $search == "latest-pre" ]; then
        docker tag $git_dst_repo:$tag $git_dst_repo:latest-pre
        docker push $git_dst_repo:latest-pre
    fi
}

function usage(){
    echo "Usage: GIT_PUSH_TOKEN=abcdef sudo bash build.sh <tag_name>"
    echo "Supported Tags:"
    echo "  - latest ... latest stable version"
    echo "  - latest-pre ... latest version including prereleases"
    echo "  - v0.6.5-0 ... all tags used in the repo url /releases/tag/<tag_name>"
    exit 1
}

function root(){
    if [ 0 -ge $(id | grep root | wc -l) ]; then
        echo "Script was not run as root. Exiting."
        exit 1
    fi
}

# read parameters
TEMP=`getopt -o h --long help -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h|--help)
            usage ; break ;;
        --) root
            url=$(find_url)
            tag=$(find_tag)
            validate
            build
            login
            push ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done
