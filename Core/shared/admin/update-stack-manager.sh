touch ~/update-stack.sh && \
rm ~/update-stack.sh && \
touch ~/update-stack.sh && \
cat > ~/update-stack.sh <<EOL
rm -rf /msf
git clone -b master \
    https://rodneywimberly:30c18052b85cb37658846d156d9f50eb1bf773c2@github.com/RodneyWimberly/MicroServiceFramework.git \
    /msf
cd /msf/Core/shared/admin
chmod u+x ./*.sh
./deploy.sh
exit
EOL
chmod u+x ~/update-stack.sh
apk add screen git gettext curl jq
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t update-stack -S update-stack
./update-stack.sh
