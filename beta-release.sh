#!/usr/bin/env bash

set -euo pipefail

cd ../openbao

BRANCH=$(git rev-parse --abbrev-ref HEAD)

read -p "Currently on branch $BRANCH. Continue Release? type y " -n 1 -r
echo ""
if [[ $REPLY != "y" ]] ; then
    echo "aborting"
    exit 0
fi


GORELEASER_YAML="$(mktemp goreleaser.XXXXXXXX.yaml --tmpdir)"

cp goreleaser.linux.yaml "$GORELEASER_YAML"

yq -i '
    (.builds[] | select(.id == "builds-linux") | .goarch) = ["amd64"] |
    del(.nfpms[].deb) |
    del(.nfpms[].rpm) |
    del(.dockers[] | select(.id != "alpine-amd64")) |
    del(.docker_manifests) |
    (.dockers[0].image_templates) = ["ghcr.io/{{ .Env.GITHUB_REPOSITORY_OWNER }}/openbao-{{ .Branch }}-beta:{{ replace .Version \"+\" \"-\" }}-amd64"] |
    (.release.github.owner) = "{{ .Env.GITHUB_REPOSITORY_OWNER }}" |
    (.release.github.name) = "openbao-{{ .Branch }}-beta"
' "$GORELEASER_YAML"


export NIGHTLY_RELEASE=true
export GITHUB_REPOSITORY_OWNER=phil9909

export GIT_HASH=$(git rev-list --max-count=1 --abbrev-commit HEAD)
export DATE=$(date "+%Y%m%d")
export VERSION="v1.99.$DATE-$BRANCH-beta+$GIT_HASH"

echo $VERSION

git tag $VERSION

go run github.com/goreleaser/goreleaser/v2@latest release \
    --snapshot \
    --skip sbom,sign \
    --clean \
    --config "$GORELEASER_YAML"

git tag -d $VERSION
