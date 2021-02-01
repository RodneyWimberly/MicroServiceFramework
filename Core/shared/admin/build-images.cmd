@echo off

SET CONTAINER_ROOT_PATH=d:\em\core
SET IMAGE_OWNER=rodneywimberly

echo Building Docker Images

pushd %CONTAINER_ROOT_PATH%\consul
echo  --- Building %IMAGE_OWNER%/consul image
docker build -t %IMAGE_OWNER%/consul .
popd

pushd %CONTAINER_ROOT_PATH%\dns
echo  --- Building %IMAGE_OWNER%/dns image
docker build -t %IMAGE_OWNER%/dns .
popd

pushd %CONTAINER_ROOT_PATH%\portal
echo  --- Building %IMAGE_OWNER%/portal image
docker build -t %IMAGE_OWNER%/portal .
popd

pushd %CONTAINER_ROOT_PATH%\vault
echo  --- Building %IMAGE_OWNER%/vault image
docker build -t %IMAGE_OWNER%/vault .
popd

