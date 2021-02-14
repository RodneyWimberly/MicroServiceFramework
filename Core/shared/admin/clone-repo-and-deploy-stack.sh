touch ~/clone-repo-and-deploy-stack.sh && \
rm ~/clone-repo-and-deploy-stack.sh && \
touch ~/clone-repo-and-deploy-stack.sh && \
cat > ~/clone-repo-and-deploy-stack.sh <<EOL
if [[ -d ~/msf ]]; then
  ~/msf/Core/shared/admin/shutdown-cluster.sh
fi
cd ~/
rm -fr ~/msf
git clone -b DeployCore \
  https://rodneywimberly:30c18052b85cb37658846d156d9f50eb1bf773c2@github.com/RodneyWimberly/MicroServiceFramework.git \
  ~/msf
chmod -Rv u+x ~/msf/Core/shared/*
cd ~/msf/Core/shared/admin
./deploy-cluster.sh
exit
EOL
chmod u+x ~/clone-repo-and-deploy-stack.sh
./clone-repo-and-deploy-stack.sh
