#!/bin/bash
#######################################################################
#
#
#
#
#
#
#
#
#
#######################################################################

#
# Add ppas
PPAS=(
   "ppa:saiarcot895/myppa"
   "ppa:git-core/ppa"
  )


printf "Please enter the admin passwd: \n"
sudo echo ""


printf "\nInstalling PPA(s):\n"
for i in ${PPAS[@]}; do
    printf  "  - Adding ppa: $i...  "
    sudo apt-add-repository -y $i 2> /dev/null
done


#
# install apt-fast
#   - need to automate install and config of apt-fast
printf "\nInstalling base apps\n"
sudo apt update
sudo apt install -y apt-fast di axel build-essential
sudo apt-fast dist-upgrade -y
sudo apt-fast install -y apt-transport-https ca-certificates

# setup docker
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list



printf "\nConfiguring apt-fast\n"
sudo cp -pv /usr/share/bash-completion/completions/apt-fast /etc/bash_completion.d

# install docker
sudo apt-fast update && sudo apt-fast install -y docker-engine docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER

#
# determine vbox version
#   - place holder

