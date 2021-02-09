touch ~/clone-repo-and-deploy-stack.sh && \
rm ~/clone-repo-and-deploy-stack.sh && \
touch ~/clone-repo-and-deploy-stack.sh && \
cat > ~/clone-repo-and-deploy-stack.sh <<EOL
if [[ -d ~/msf ]]; then
  cd ~/msf
  ./Core/shared/admin/shutdown-cluster.sh
  git pull https://rodneywimberly:30c18052b85cb37658846d156d9f50eb1bf773c2@github.com/RodneyWimberly/MicroServiceFramework.git
else
  git clone -b DeployCore \
    https://rodneywimberly:30c18052b85cb37658846d156d9f50eb1bf773c2@github.com/RodneyWimberly/MicroServiceFramework.git \
    ~/msf
fi
cd ~/msf/Core/shared/admin
chmod u+x ./*.sh
cp ~/msf/Core/shared/admin/docker-node-ps /bin/docker-node-ps
cp ~/msf/Core/shared/admin/docker-service-exec /bin/docker-service-exec
./deploy-cluster.sh
exit
EOL
chmod u+x ~/clone-repo-and-deploy-stack.sh
apk add screen git gettext curl jq
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "192.168.0.28 worker1" >> /etc/hosts
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t stack-deployment -S stack-deployment
./clone-repo-and-deploy-stack.sh
