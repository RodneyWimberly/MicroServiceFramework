#!/bin/bash
set -ueo pipefail
set +x

run() {
    
        
    if [ ! -f ~/.runonce ]; then
        apk add \
            screen \
            git \
            gettext \
            curl \
            jq \
            rsync \
            gawk \
            nano \
            keychain \
            wget \
            iputils \
            iproute2 \
            bind-tools \
            bash \
            unzip \
            ca-certificates \
            procps \
            vim \
            rsyslog \
            su-exec \
            openrc
        mkdir -p /run/openrc
        touch /run/openrc/softlevel
        rc-update add rsyslog default
        export TINI_VERSION=v0.19.0
        curl -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download//tini
        chmod +x /usr/local/bin/tini
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa
        echo "192.168.0.7 worker1" >> /etc/hosts
        echo "192.168.0.8 manager1" >> /etc/hosts
        ssh -tt worker1 'echo "Connected!"'
        ssh -tt manager1 'echo "Connected!"'
        echo "caption always \"%{= kc}Screen session %S on %H CTRL + A=hotkey/D=detach/ESC=scroll/:=cmd %-20=%{= .m}%D %d.%m.%Y %0c\"" > ~/.screenrc
        echo "defscrollback 200000" >> ~/.screenrc
        touch ~/.runonce
    fi
    # export PATH=~/msf:~/msf/core:"$/root/.nvm/versions/node/v16.13.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Program Files/Eclipse Foundation/jdk-8.0.302.8-hotspot/bin:/mnt/c/Python39/Scripts/:/mnt/c/Python39/:/mnt/c/Program Files (x86)/Microsoft SDKs/Azure/CLI2/wbin:/mnt/c/Program Files (x86)/Intel/iCLS Client/:/mnt/c/Program Files/Intel/iCLS Client/:/mnt/c/Program Files/Microsoft MPI/Bin/:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/c/Program Files/dotnet/:/mnt/c/Program Files/Microsoft SQL Server/130/Tools/Binn/:/mnt/c/Program Files (x86)/Microsoft SQL Server/140/Tools/Binn/:/mnt/c/Program Files/Microsoft SQL Server/140/Tools/Binn/:/mnt/c/Program Files (x86)/Microsoft SQL Server/140/DTS/Binn/:/mnt/c/Program Files/Microsoft SQL Server/140/DTS/Binn/:/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/:/mnt/c/Program Files (x86)/Intel/Intel(R) Management Engine Components/DAL:/mnt/c/Program Files/Intel/Intel(R) Management Engine Components/DAL:/mnt/c/Program Files (x86)/Intel/Intel(R) Management Engine Components/IPT:/mnt/c/Program Files/Intel/Intel(R) Management Engine Components/IPT:/mnt/c/Program Files (x86)/GtkSharp/2.12/bin:/mnt/c/Program Files/Intel/WiFi/bin/:/mnt/c/Program Files/Common Files/Intel/WirelessCommon/:/mnt/c/Program Files/PuTTY/:/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/:/mnt/c/Program Files (x86)/Windows Kits/10/Windows Performance Toolkit/:/mnt/c/Program Files (x86)/Windows Kits/10/Microsoft Application Virtualization/Sequencer/:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files/Microsoft/Web Platform Installer/:/mnt/c/Program Files/Microsoft Service Fabric/bin/Fabric/Fabric.Code:/mnt/c/Program Files (x86)/Microsoft SQL Server/150/DTS/Binn/:/mnt/c/Program Files/Azure Data Studio/bin:/mnt/c/Program Files (x86)/IncrediBuild:/mnt/c/Program Files/TortoiseGit/bin:/mnt/c/Program Files/Go/bin:/mnt/c/Program Files/PowerShell/7/:/mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin:/mnt/c/Program Files/nodejs/:/mnt/c/Program Files/Git/cmd:/mnt/c/Users/Rodney/AppData/Local/Programs/Python/Python310/Scripts/:/mnt/c/Users/Rodney/AppData/Local/Programs/Python/Python310/:/mnt/c/Users/Rodney/scoop/shims:/mnt/c/Program Files/MySQL/MySQL Shell 8.0/bin/:/mnt/c/Users/Rodney/.dotnet/tools:/mnt/c/Users/Rodney/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/Rodney/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Rodney/AppData/Local/GitHubDesktop/bin:/mnt/c/Users/Rodney/AppData/Local/Programs/Fiddler:/mnt/c/Users/Rodney/.dotnet/tools:/mnt/c/Program Files (x86)/Rico Suter/NSwagStudio/:/mnt/c/Program Files/Java/jdk1.8.0_181:/mnt/c/Users/Rodney/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/Sublime Text 3:/mnt/c/Users/Rodney/AppData/Local/hyper/app-3.0.2/resources/bin:/mnt/c/Users/Rodney/go/bin:/mnt/c/Users/Rodney/AppData/Roaming/npm:/snap/bin:/root/.dotnet/tools"
    screen -q -t node-manager -S node-manager
}

run
