@echo off
pushd

rem ==================================================
SET CONTAINER_ROOT_PATH=d:\em\core
SET IMAGE_OWNER=rodneywimberly

rem ==================================================
echo "Building Docker Images"

cd %CONTAINER_ROOT_PATH%\consul
echo " --> Building %IMAGE_OWNER%/consul image"
docker build -t %IMAGE_OWNER%/consul .

cd %CONTAINER_ROOT_PATH%\dns
echo " --> Building %IMAGE_OWNER%/dns image"
docker build -t %IMAGE_OWNER%/dns .

cd %CONTAINER_ROOT_PATH%\portal
echo " --> Building %IMAGE_OWNER%/portal image"
docker build -t %IMAGE_OWNER%/portal .

cd %CONTAINER_ROOT_PATH%\vault
echo " --> Building %IMAGE_OWNER%/vault image"
docker build -t %IMAGE_OWNER%/vault .

popd
