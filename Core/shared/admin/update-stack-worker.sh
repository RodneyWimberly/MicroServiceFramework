touch ~/update-stack.sh && \
rm ~/update-stack.sh && \
touch ~/update-stack.sh && \
cat > ~/update-stack.sh <<EOL
rm -rf /msf
git clone -b master \
    https://rodneywimberly:b606a0781f57605d4e5b00b753a6f26c23ff8908@github.com/RodneyWimberly/MicroServiceFramework.git \
    /msf
cd /msf/Core/shared/admin
chmod u+x ./*.sh
exit
EOL
chmod u+x ~/update-stack.sh
apk add screen git gettext curl jq
echo "caption always \"%{= kc}Screen session %S on %H %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
screen -q -t update-stack -S update-stack
./update-stack.sh
