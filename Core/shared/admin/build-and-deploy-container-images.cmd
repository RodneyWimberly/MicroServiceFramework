@echo off

SET CONTAINER_ROOT_PATH=d:\em\core
SET IMAGE_OWNER=microserviceframework
SET IMAGE_TAG=dev
SET DOCKER_HUB=docker.io
SET DOCKER_USER=rodneywimberly
SET DOCKER_PASSWORD=P@55w0rd

echo Building and Deploying Docker Images

echo  --- Logging in to Docker hub
docker login --username=%DOCKER_USER% --password=%DOCKER_PASSWORD%

SET IMAGE_NAME=consul
pushd %CONTAINER_ROOT_PATH%\%IMAGE_NAME%
echo  --- Building %IMAGE_OWNER%/%IMAGE_NAME% image
docker build -t %IMAGE_OWNER%/%IMAGE_NAME% .
docker tag %IMAGE_OWNER%/%IMAGE_NAME% %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
docker push %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
popd

SET IMAGE_NAME=dns
pushd %CONTAINER_ROOT_PATH%\%IMAGE_NAME%
echo  --- Building %IMAGE_OWNER%/%IMAGE_NAME% image
docker build -t %IMAGE_OWNER%/%IMAGE_NAME% .
docker tag %IMAGE_OWNER%/%IMAGE_NAME% %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
docker push %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
popd

SET IMAGE_NAME=portal
pushd %CONTAINER_ROOT_PATH%\%IMAGE_NAME%
echo  --- Building %IMAGE_OWNER%/%IMAGE_NAME% image
docker build -t %IMAGE_OWNER%/%IMAGE_NAME% .
docker tag %IMAGE_OWNER%/%IMAGE_NAME% %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
docker push %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
popd

SET IMAGE_NAME=vault
pushd %CONTAINER_ROOT_PATH%\%IMAGE_NAME%
echo  --- Building %IMAGE_OWNER%/%IMAGE_NAME% image
docker build -t %IMAGE_OWNER%/%IMAGE_NAME% .
docker tag %IMAGE_OWNER%/%IMAGE_NAME% %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
docker push %IMAGE_OWNER%/%IMAGE_NAME%:%IMAGE_TAG%
popd

