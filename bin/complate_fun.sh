sudo cp -f bin/tea_complate /usr/share/bash-completion/completions/tea
( cat ~/.bashrc | grep -q tea_ctl )|| echo "alias tea_ctl='sh bin/tea_ctl.sh'" >> ~/.bashrc

source /usr/share/bash-completion/completions/tea
source ~/.bashrc