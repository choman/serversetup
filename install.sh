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

printf "\nConfiguring apt-fast\n"
sudo cp -pv /usr/share/bash-completion/completions/apt-fast /etc/bash_completion.d


#
# determine vbox version
#   - place holder

