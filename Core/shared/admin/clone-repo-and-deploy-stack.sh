touch ~/clone-repo-and-deploy-stack.sh && \
rm ~/clone-repo-and-deploy-stack.sh && \
touch ~/clone-repo-and-deploy-stack.sh && \
cat > ~/clone-repo-and-deploy-stack.sh <<EOL
rm -rf ~/msf
git clone -b DeployCore \
    https://rodneywimberly:30c18052b85cb37658846d156d9f50eb1bf773c2@github.com/RodneyWimberly/MicroServiceFramework.git \
    ~/msf
cd ~/msf/Core/shared/admin
chmod u+x ./*.sh
./cluster-deploy.sh
exit
EOL
chmod u+x ~/clone-repo-and-deploy-stack.sh
apk add screen git gettext curl jq
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t stack-deployment -S stack-deployment
./clone-repo-and-deploy-stack.sh