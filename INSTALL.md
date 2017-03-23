Notes on installation of the docker server and the containers

Primary Install:
- Edit the config file
- run the install script ./install.sh
- reboot

Docker Vault:
- cd docker_vault
- run the run.sh script
- edit the setup.sh script
- run the setup.sh script
- mv the files (token & keys) to the client (scp)
   NOTE: if the client is dehind a NAT, you may need to 
         scp to this server from there

FreeIPA:
- cd freeipa-server
- cp myenv.template myenv
- edit the myenv file
- ./build.sh - this may take a while
- ./run.sh


Logstash:
- cd myelk-docker
