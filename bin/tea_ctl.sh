#!/bin/bash
#  Create & manage k8s clusters

set -o nounset
set -o errexit
#set -o xtrace

function create_user() {
    echo "params: " ${@:1}  ", params count: "$#
    case "$1" in 
    -U |-u )
      [ "$#" -gt 3 ] && { create_user help >&2; exit 2; } # param > 3
      echo "please input remote user $2 password "
      [ "$#" -eq 2 ] && { ansible-playbook -i hosts.ini playbooks/create_user.yml -u $2  -k ; exit 0; } # all node
      echo "remote ip: " ${@:3}
      ansible-playbook -i hosts.ini playbooks/create_user.yml -u $2  -k  -l ${@:3} ; exit 0;# limit ip
      ;;
    help| --help| -h |*)
     echo -e "\033[33mUsage:\033[0m ctea_ctl create_user [OPTION] "
    cat <<EOF
create a new user on nodes

  [OPTION]
    -U , -u                      remote ssh user

  Examples:
    tea_ctl create_user -u root 
    tea_ctl create_user -u root 10.10.2.13
    tea_ctl create_user -u root 10.10.2.13,10.10.2.14
EOF
    ;;
    * )
      echo -e "\033[33mUsage:\033[0m please set remote user with -u or -U "
      exit 0
      ;;
  esac
}

function check_user_ssh(){
  [ "$#" -gt 1 ] && { usage >&2; exit 2; }
  declare -r username=`cat hosts.ini | grep ^username | cut -d '=' -f2 `
  echo "ssh remote nodes user: " $username
  ansible -i hosts.ini nodes -m shell -a 'whoami' -u $username -b
}

function use_repo(){
  [ "$#" -eq 0 ] &&  { ansible-playbook -i hosts.ini playbooks/use_repo.yml ; exit 0;}
  case "$1" in
    help|--help|-h)
      echo -e "\033[33mUsage:\033[0m ctea_ctl use_repo [ip1,ip2] "
      cat <<EOF
add tea.repe to nodes
  Examples:
    tea_ctl use_repo                            # all nodes
    tea_ctl use_repo 10.10.2.13                 # limit one node
    tea_ctl use_repo 10.10.2.13,10.10.2.14      # limit nodes
EOF

  exit 0;
    ;;
  esac

  [ "$#" -eq 1 ] &&  { ansible-playbook -i hosts.ini playbooks/use_repo.yml -l ${@:1} ; exit 0; } 
 
}

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


function usage() {
    echo -e "\033[33mUsage:\033[0m tea_ctl COMMAND [args]"
    cat <<EOF
-------------------------------------------------------------------------------------
  COMMAND:
    create_user                      create a new user on nodes
    check_user_ssh                   check user ssh login remote nodes
    use_repo                         add tea.repe to nodes

  Examples:
    tea_ctl create_user -u root                        # all nodes
    tea_ctl create_user -u root 10.10.2.13             # limit one node
    tea_ctl create_user -u root 10.10.2.13,10.10.2.14  # limit nodes 

    tea_ctl use_repo                            # all nodes
    tea_ctl use_repo 10.10.2.13                 # limit one node
    tea_ctl use_repo 10.10.2.13,10.10.2.14      # limit nodes  

Use "teactl <command> help" for more information about a given command.
EOF
}

function service(){
  #  echo "params: " ${@:1}  ", params count: "$#
  [ $2 == 'delete' ] && { echo 'are you sure !!!!! ' ; exit 0; }
   cmd="ansible-playbook  playbooks/$2_$1.yml ${@:3}"
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
  # echo "params: " ${@:1}  ", params count: "$#
  
  case "$1" in
      ### in-cluster operations #####################
      create_user)
          [ "$#" -eq 1 ] && { create_user help; exit 2; } ## no params
          # [ "$#" -gt 1 ] || { usage >&2; exit 2; } 
          create_user "${@:2}" 
          exit 0
          ;;
      check_user_ssh)
          [ "$#" -gt 1 ] && { usage >&2; exit 2; }
          check_user_ssh 
          exit 0
          ;;    
      use_repo)
          # [ "$#" -gt 1 ] && { usage >&2; exit 2; }
          use_repo "${@:2}"
          exit 0
          ;;   
      service)
          # [ "$#" -gt 1 ] && { usage >&2; exit 2; }
          service "${@:2}"
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