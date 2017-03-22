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

function setup_vault() {
    vers=0.7.0

    if [ ! -f /usr/local/bin/vault ]; then
        wget -nc -O /tmp/vault.zip https://releases.hashicorp.com/vault/${vers}/vault_${vers}_linux_amd64.zip
        sudo unzip /tmp/vault.zip -d /usr/local/bin
    fi

}


function parse_yaml2() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
      indent = length($1)/2;
      if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
              vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
              printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
      }
    }' | sed 's/_=/+=/g'
}

eval parse_yaml2 config "CONFIG_"
eval $(parse_yaml2 config "CONFIG_")

setup_vault

##if $DEBUG; then
##    for i in ${CONFIG_ppas[@]}; do
##        if [[ $i == ppa* ]]; then
##            echo "PPA = $i"
##        else
##            echo "Setting up: $i"
##            echo "  - $CONFIG_ppas___url"
##            echo "  - $CONFIG_ppas___sfile"
##            echo "  - $CONFIG_ppas___key"
##        fi
##    done
##    exit
##fi

printf "Please enter the admin passwd: \n"
sudo echo ""


if [ -f /var/lib/dpkg/lock ]; then
    sudo rm /var/lib/dpkg/lock
fi

IFS=""
printf "\nInstalling PPA(s):\n"
for i in ${CONFIG_ppas[@]}; do
    if [[ $i == ppa* ]]; then
        printf  "  - Adding ppa: $i...  "
        sudo apt-add-repository -y $i 2> /dev/null
    else
        appname=$(echo $i | sed -e 's/://' -e 's/[[:space:]]*$//')

        # get app info
        # make debug statement
        #printf  "  - Parsing ppa: $appname...  \n"

        eval myvar=( \${CONFIG_ppas_$appname[@]} )
        url=""
        sfile=""
        item=""
        var=""
        key=""

        for z in ${myvar[@]}; do
           eval var=$(echo $z | awk -F: '{print $1}')
           len=$(expr ${#var} + 1)
           item=$(echo ${z:$len} | sed -e 's/^[[:space:]]//')
           if [[ $var == key ]]; then
              key=$item
           else
              if [[ $var == url ]]; then
                 url=$item
              else
                 sfile=$item
              fi
           fi
        done

        printf  "  - Adding ppa: $appname...  "
        sudo sh -c "echo '$url' > $sfile"
        wget -q -O - $key | sudo apt-key add -
    fi
done

#
# install apt-fast
#   - need to automate install and config of apt-fast
printf "\nInstalling base apps\n"
sudo apt-get update

#
# update repo and install prereqs
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast
sudo cp -v files/apt-fast.conf /etc
sudo cp -v /usr/share/bash-completion/completions/apt-fast /etc/bash_completion.d/

#
sudo apt-fast install -y di axel aria2 git build-essential


git submodule update --init --remote
for dir in docker_vault freeipa-server myelk-docker
do
    echo "updating: $dir"
    (cd $dir; git submodule update --init --remote)
done

#
sudo apt-fast dist-upgrade -y

#
# determine vbox version
#   - place holder
if [ $(getent group vboxsf) ]; then
    sudo usermod -aG vboxsf $USER
fi

sudo apt-fast install -y apt-transport-https ca-certificates ssh \
                         meld autofs tmux vlock


# install lynis
git clone https://github.com/CISOfy/lynis $HOME/lynis
   

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

echo "configuring /etc/hosts"
echo "$CONFIG_freeipa__ip      $CONFIG_freeipa__hostname  $CONFIG_freeipa__fqdn" | sudo tee -a /etc/hosts

# enable ufw
sudo ufw enable

