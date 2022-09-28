#!/bin/bash
#  Create & manage k8s clusters

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

function create_user() {  
  cmd="ansible-playbook -i hosts.ini playbooks/create_user.yml -k ${@}"
  echo $cmd
  declare -r remote_user=`cat hosts.ini | grep ^remote_user | cut -d '=' -f2 `
  echo "SSH username: "$remote_user
  eval $cmd
}

function check_user_ssh(){
  # [ $1 == '-l' ] || { usage_tealab >&2; exit 2; }
  declare -r username=`cat hosts.ini | grep ^username | cut -d '=' -f2 `
  cmd="ansible -i hosts.ini nodes -m shell -a 'whoami' -u $username -b"
  echo $cmd
  eval $cmd
}
function use_repo(){
  # declare -r username=`cat hosts.ini | grep ^username | cut -d '=' -f2 ` 
  cmd="ansible-playbook -i hosts.ini playbooks/use_repo.yml"
  echo $cmd
  eval $cmd
}


function usage_init() {
    echo -e "\033[33mUsage:\033[0m tea_ctl COMMAND [args]"
    cat <<EOF
-------------------------------------------------------------------------------------
  COMMAND:
    create_user                      create a new user on nodes
    check_user_ssh                   check user ssh login remote nodes
    use_repo                         add tea.repe to nodes
    

  Examples:
    tea_ctl init create_user                       # all nodes
    tea_ctl init create_user -l 10.10.2.13             # limit one node
    tea_ctl init create_user -l 10.10.2.13,10.10.2.14  # limit nodes 

    tea_ctl init use_repo                            # all nodes
    tea_ctl init use_repo 10.10.2.13                 # limit one node
    tea_ctl init use_repo 10.10.2.13,10.10.2.14      # limit nodes  

Use "teactl <command> help" for more information about a given command.
EOF
}

function usage() {
    echo -e "\033[33mUsage:\033[0m tea_ctl COMMAND [args]"
    cat <<EOF
-------------------------------------------------------------------------------------
  COMMAND:
    init                             init tea evn
    etcd                             manager etcd cluster
    minio                         add tea.repe to nodes

  Examples:
    teactl etcd 
                create
                add
                delete
                migrate
                backup
                restore
           minio
                create 
                 
Use "teactl <command> help" for more information about a given command.
EOF
}

function service(){
  #  echo "params: " ${@:1}  ", params count: "$#
  # [ $2 == 'delete' ] && { echo 'are you sure !!!!! ' ; exit 0; }
   cmd="ansible-playbook -i hosts.ini playbooks/$2_$1.yml ${@:3}"
   echo $cmd
   eval $cmd
}

### Main Lines ##################################################
function main() {
  # BASE="/tmp/tea"
  # [[ -d "$BASE" ]] || { logger error "invalid dir:$BASE, try: 'ezdown -D'"; exit 1; }
  # cd "$BASE"

  # check bash shell
  readlink /proc/$$/exe|grep -q "bash" || { logger error "you should use bash shell only"; exit 1; } 

  # check 'ansible' executable
  which ansible > /dev/null 2>&1 || { logger error "need 'ansible', try: 'pip install ansible'"; usage; exit 1; }
  
  [ "$#" -gt 0 ] || { usage >&2; exit 2; }
  echo "begin  params: " ${@:1}  ", params count: "$#

  case "$1" in
      ### in-cluster operations #####################
      
      init)
          case "$2" in 
            create_user)
              create_user ${@:3}
              exit 0
            ;;
            check_user_ssh)
              check_user_ssh ${@:3}
              exit 0
              ;;
            use_repo)
              use_repo ${@:3}
              ;;
            help| --help|-h)
              usage_tealab 
              exit 0
              ;;
          esac
          ;; 
      service)
          # [ "$#" -gt 1 ] && { usage >&2; exit 2; }
          service "${@:2}"
          exit 0
          ;;
      minio)
        service  "${@:1}"
        exit 0
          ;;    
      help|--help|-h)
          [ "$#" -gt 1 ] || { usage >&2; exit 2; }
          usage
          exit 0
          ;;
      *)
          usage
          exit 0
          ;;
  esac
 }

main "$@" 