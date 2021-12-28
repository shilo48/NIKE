powershell vboxmanage registervm "C:\Users\yhanin\Documents\vm\AirMachine_Base\AirMachine_Base.vbox"
start-sleep -Seconds 5 
powershell vboxmanage modifyvm AirMachine_Base --macaddress1 auto --macaddress2 auto
start-sleep -Seconds 5 

powershell vboxmanage startvm AirMachine_Base # --type headless

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt-get update"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt list --upgradable"

#sudo rm /var/lib/dpkg/lock
#sudo rm /var/lib/dpkg/lock-frontend
#sudo rm /var/cache/apt/archives/lock
#sudo apt update
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt-get upgrade"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo useradd -p $(openssl passwd -1 password1) username"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo echo 'username ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/dont-prompt-username-for-sudo-password"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo git config --global user.name 'username'"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo git config --global user.email 'password@airspan.com'"
#sudo git config --global --get user.name
#sudo git config --global --get user.email
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo useradd  -p $(openssl passwd -1 smbpasswd) smbpasswd"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo service smbd restart"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo service nmbd restart"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo cp /etc/fstab /etc/fstab.orig"
#vboxmanage startvm AirMachine_Base --type emergencystop
#VBoxManage sharedfolder add "AirMachine_Base"  --name common  --hostpath  "//fs4/Common" --auto-mount-point=k --automount
#VBoxManage guestproperty set "AirMachine_Base" "/VirtualBox/GuestAdd/SharedFolders/MountDir" "k"
#VBoxManage guestproperty set "AirMachine_Base" "/VirtualBox/GuestAdd/SharedFolders/MountPrefix" ""
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo cp /etc/fstab /etc/fstab.orig"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed -i 's!/Windows/Projects!/p!g' /etc/fstab"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed -i 's!/Windows/Data!/t!g' /etc/fstab"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed -i 's!/Windows/Common!/k!g' /etc/fstab"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed -i 's/uid=1000/uid=1002/g' /etc/fstab"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed -i 's/gid=1000/gid=1002/g' /etc/fstab"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo mkdir /p /t /k"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo mount -a"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"
#VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` test""
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt update -y"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt install -y docker-ce docker-ce-cli containerd.io"


VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.orig"
sed '$!N;s/^.*\n.*ExecStart/ExecStart= &/;P;D' docker.service
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed '$!N;s/^.*\n.*ExecStart/ExecStart= &/;P;D' docker.service"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo sed  '/fd:/ s/$/ --insecure-registry harbor-il:9090' docker.service"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo systemctl daemon-reload"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo systemctl restart docker"
VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo usermod -aG docker $USER"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo add-apt-repository ppa:deadsnakes/ppa"

VBoxManage guestcontrol "AirMachine_Base" run /bin/sh --username master --password master --verbose --wait-stdout --wait-stderr -- -c "sudo apt-get install -y python3.6 libxml2-dev libxslt1-dev python-dev python-lxml python3-lxml python3-git"

VBoxManage snapshot "AirMachine_Base" take "AirMachinePostBuild" --live
VBoxManage snapshot "AirMachine_Base" list