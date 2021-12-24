#!/bin/bash
set -ueo pipefail
set +x

# shellcheck source=../../../shared/scripts/development-functions.sh
. /mnt/d/msf/shared/scripts/development-functions.sh

pushd /mnt/d/msf/auth || exit 1

IMAGE_TAG=${1:-dev}
log_header "auth: Building and Publishing Docker Images with Tag: $IMAGE_TAG"

if $BUILD_AUTH_DB; then
    build_and_deploy_image "auth-db" "$IMAGE_TAG"
fi
if $BUILD_AUTH_API; then
    log_detail "Publishing DotNet Package: Auth-Api"
    rm -r -d -f ./auth-api/bld
    dotnet publish ./src/Admin/Api/Api.csproj -o ./auth-api/bld
    build_and_deploy_image "auth-api" "$IMAGE_TAG"
fi
if $BUILD_AUTH_ADMIN; then
    log_detail "Publishing DotNet Package: Auth-Admin"
    rm -r -d -f ./auth-admin/bld
    dotnet publish ./src/Admin/Web/Web.csproj -o ./auth-admin/bld
    build_and_deploy_image "auth-admin" "$IMAGE_TAG"
fi
if $BUILD_AUTH_STS; then
    log_detail "Publishing DotNet Package: Auth-Sts"
    rm -r -d -f ./auth-sts/bld
    dotnet publish ./src/Web/Web.csproj -o ./auth-sts/bld
    build_and_deploy_image "auth-sts" "$IMAGE_TAG"
fi

popd