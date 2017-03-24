#!/bin/bash -e

# This script builds and uploads copy-pasta cli to Github.
#
#   You need to export one environment variable called GITHUB_TOKEN.
#   You should be able to create one token at https://github.com/settings/applications
#   This script assumes that you have github-release installed (https://github.com/aktau/github-release).
#
# Usage:
#
#   % ./create-package.sh

download_copy_pasta_source_code(){
    echo -n "Downloading copy-pasta source... "
    mkdir -p /tmp/copy-pasta/src /tmp/copy-pasta/pkg
    GOPATH=/tmp/copy-pasta go get -d github.com/jutkko/copy-pasta/...
    pushd /tmp/copy-pasta/src/github.com/jutkko/copy-pasta > /dev/null 2>&1
    git checkout master >/dev/null 2>&1
    echo "ok"
    echo -n "Restoring dependencies... "
    GOPATH=/tmp/copy-pasta godep restore ./...
    popd > /dev/null 2>&1
    echo "ok"
}

get_copy_pasta_version(){
    GOPATH=/tmp/copy-pasta go build -o copy-pasta github.com/jutkko/copy-pasta
    echo "$(./copy-pasta --version 2>&1)"
    rm copy-pasta
}

package(){
    echo -n "Creating package... "
    pushd /tmp/copy-pasta
    tar -czf $1 *
    shasum -a 256 $1
    popd
    echo "ok"
}

update_formula(){
    local current_path copy_pasta_version tarball
    current_path="$1"
    tarball="$2"
    copy_pasta_version="$3"

    echo -n "Updating and tagging formula..."
    file_path=${destination_dir}/$tarball
    sha=$(shasum -a 256 ${file_path}|cut -d " " -f 1)
    github_tarball_link=$(echo "https://github.com/jutkko/copy-pasta/releases/download/$copy_pasta_version/$tarball" | sed 's/\//\\\//g')
    github_link=${github_tarball_link/.tar.gz/}
    sed -i "" "s/url '.*'/url '${github_link}'/g" ${current_path}/../Formula/copy-pasta.rb
    sed -i "" "s/sha256 '.*'/sha256 '${sha}'/g" ${current_path}/../Formula/copy-pasta.rb
    echo "ok"
}


configure_build_environment(){
    echo -n "Creating \"$1\" directory... "
    mkdir -p $1
    echo "ok"
}

upload_release_to_github(){
    local current_path destination_dir copy_pasta_version

    current_path="$1"
    destination_dir="$2"
    copy_pasta_version="$3"

    package "${destination_dir}/copy-pasta-${copy_pasta_version}.tar.gz"

    cd ${destination_dir}
    echo -n "Uploading file to Github... "
    github-release release --security-token $GITHUB_TOKEN --user jutkko --repo copy-pasta --tag ${copy_pasta_version} --pre-release
    github-release upload --security-token $GITHUB_TOKEN --user jutkko --repo copy-pasta --tag ${copy_pasta_version} --name copy-pasta-${copy_pasta_version} --file copy-pasta-${copy_pasta_version}.tar.gz
    echo "ok"
    update_formula  $current_path copy-pasta-${copy_pasta_version}.tar.gz ${copy_pasta_version}

    echo -n "Removing temporary folder..."
    rm -rf /tmp/copy-pasta
    echo "ok"

    echo -n "Generating tag and commiting..."
    cd ${current_path}/..
    git commit -am ${copy_pasta_version}
    git tag ${copy_pasta_version}
    echo "ok"
}

main(){
    local destination_dir current_path copy_pasta_version

    current_path="$(pwd)"
    destination_dir="/tmp/dist-src"

    configure_build_environment "${destination_dir}"

    download_copy_pasta_source_code

    copy_pasta_version=$(get_copy_pasta_version)

    upload_release_to_github "${current_path}" "${destination_dir}" "${copy_pasta_version}"
}

main

