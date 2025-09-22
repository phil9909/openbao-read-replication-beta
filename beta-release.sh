#!/usr/bin/env bash

set -euo pipefail

RELEASE_NOTES="$(cat NOTES.md)"
export RELEASE_NOTES

cd ../openbao

BRANCH=$(git rev-parse --abbrev-ref HEAD)

read -p "Currently on branch $BRANCH. Continue Release? type y " -n 1 -r
echo ""
if [[ $REPLY != "y" ]] ; then
    echo "aborting"
    exit 0
fi

export NIGHTLY_RELEASE=true
export GITHUB_REPOSITORY_OWNER=phil9909

export GIT_HASH=$(git rev-list --max-count=1 --abbrev-commit HEAD)
export DATE=$(date "+%Y%m%d")
export VERSION="v1.99.$DATE-$BRANCH-beta+$GIT_HASH"

GORELEASER_YAML="$(mktemp goreleaser.XXXXXXXX.yaml --tmpdir)"
echo $GORELEASER_YAML

trap cleanup EXIT

cleanup() {
    echo "removing $GORELEASER_YAML"
    rm -f $GORELEASER_YAML
    echo "removing tag"
    git tag -d "$VERSION"
}

cp goreleaser.linux.yaml "$GORELEASER_YAML"

yq -i '
    (.builds[] | select(.id == "builds-linux") | .goarch) = ["amd64"] |
    del(.nfpms[].deb) |
    del(.nfpms[].rpm) |
    del(.dockers[] | select(.id != "alpine-amd64")) |
    del(.docker_manifests) |
    (.dockers[0].image_templates) = ["ghcr.io/{{ .Env.GITHUB_REPOSITORY_OWNER }}/openbao-{{ .Branch }}-beta:{{ replace .Version \"+\" \"-\" }}-amd64"] |
    (.dockers[0].skip_push) = true |
    (.release.github.owner) = "{{ .Env.GITHUB_REPOSITORY_OWNER }}" |
    (.release.github.name) = "openbao-{{ .Branch }}-beta" |
    (.release.target_commitish) = "main" |
    (.release.header) = strenv(RELEASE_NOTES)
' "$GORELEASER_YAML"

echo $VERSION

git tag $VERSION

go run github.com/goreleaser/goreleaser/v2@latest release --verbose \
    --skip sbom,sign \
    --clean \
    --config "$GORELEASER_YAML"
