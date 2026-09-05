#!/bin/bash

set -e

VERSION="${VERSION:-$(git describe --tags --always 2>/dev/null || echo "v2.2.2-beta")}"
echo -n "${VERSION}" > .version

go test

cd ../pkg/metadata
go test
cd ../../app

cd ../pkg/plugins
go test
cd ../../app

cd ../pkg/update
go test
cd ../../app

# cd ../tools/sitegen
# echo -n $VERSION > .version
# go test -short
# cd ../../app
