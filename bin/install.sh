#!/bin/bash
#  Install tealab 

set -o nounset
set -o errexit
#set -o xtrace

function logger() {
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  case "$1" in
    debug)
      echo -e "$TIMESTAMP \033[36mDEBUG\033[0m $2"
      ;;
    info)
      echo -e "$TIMESTAMP \033[32mINFO\033[0m $2"
      ;;
    warn)
      echo -e "$TIMESTAMP \033[33mWARN\033[0m $2"
      ;;
    error)
      echo -e "$TIMESTAMP \033[31mERROR\033[0m $2"
      ;;
    *)
      ;;
  esac
}

function create_tea_user() {
  logger info "create user for tea"
#   read  -p "请输入用户名 default[tea]：" username

#   if [ -z "${username}" ];then
#         username="tea"
#   fi
  username="tea"

  logger info "create user for tea : $username"

  id $username &>/dev/null
  
  if [ $? -ne 0 ];then
    useradd -m -d /home/$username $username
  fi

  logger info "create user for tea complate"

  logger info "sudo private"
  echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

  if [ ! -f '/home/tea/.ssh/id_rsa' ]; then

    logger info "generate ssh key"
    su - $username  -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
    logger info "generate ssh key complate"
  fi
}

function ready_tea_code() {
  logger info "ready for tea code"
  # code 已经存在是否更新
  if [ -d "/home/tea/tealab/" ]; then
    # read  -p "tealab already exists , Overwrite (y/n)?" ow
    # echo "you enter: " $ow
    # if [[ "$ow" == "y" || "$ow" == "Y" ]]; then
      mv /home/tea/tealab/ /home/tea/tealab.back_`date +%Y-%m-%d_%H%M`
      # download_tea_code
      # rm -rf /home/tea/tealab.back/
    # fi
  # else
  fi
  download_tea_code
}

function download_tea_code(){
  tag=v0.0.2
  wget https://gitee.com/zhangeamon/tealab/repository/archive/$tag -O tealab.zip 
  unzip -quo tealab.zip -d /home/tea/
  mv /home/tea/tealab-$tag /home/tea/tealab
  logger info "download tea code complate"
}

function config_tea(){
  logger info "config tea "
  if [ ! -d "/etc/tea/" ]; then
    sudo mkdir /etc/tea/
  fi
  sudo cp /home/tea/tealab/hosts.ini.sample /etc/tea/tea.conf
  sudo cp /home/tea/tealab/ansible.cfg /etc/ansible/ansible.cfg

  sudo touch /var/log/ansible.log
  sudo chmod 644 /var/log/ansible.log
  logger info "config tea compalte"
}

function install_base_dependency() {
 # check bash shell
  readlink /proc/$$/exe|grep -q "bash" || { logger error "you should use bash shell only"; exit 1; } 

  logger info "Welcome to tealab"
  
  logger info "begin install base packages"
  yum -y install epel-release git curl sshpass wget
  logger info "install (epel-release git curl sshpass wget) complate!"

  yum -y install ansible
# check 'ansible' executable
  which ansible > /dev/null 2>&1 || { logger error "need 'ansible', try: 'yum -y install ansible'"; usage; exit 1; }
  logger info "install (ansible) complate!"

}

function main() {
# install base packages    
   install_base_dependency
   create_tea_user
   ready_tea_code 
   config_tea 
   logger info "tealab install successfull"
   logger info "user tea is recommended & config file /etc/tea/tea.conf"
   sudo su - tea
}

main "$@" 