# Install helm by default
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# USAGE: helm-upgrade -n namespace
# Must be run in the directory where you have your config.yaml file
alias helm-upgrade='~/.bash_scripts/helm-upgrade.sh -v 0.6 -i "jupyterhub/jupyterhub"'
