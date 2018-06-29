#!/bin/bash

# INSTALL JUPYTERHUB on KUBERNETES (worked for Google Cloud Platform on Cloud Shell)
# See more details: https://zero-to-jupyterhub.readthedocs.io/en/latest/getting-started.html

VERSION=0.6
while [ ! -z $1 ]; do
  case $1 in
    -v | --version) VERSION=$2; shift 2;;
    -n | --name) NAME=$2; shift 2;;
    --namespace) NAMESPACE=$2; shift 2;;
    -d | --domain) DOMAIN=$2; shift 2;;
    -a | --auth0-subdomain) AUTH0_SUBDOMAIN=$2; shift 2;;
  esac
done

if [ -z $NAME ]; then
  echo "You must define a name."
  exit 1
fi
if [ -z $NAMESPACE ]; then
  NAMESPACE=$NAME
fi
if [ -z $DOMAIN ]; then
  echo "You must define a domain."
  exit 1
fi
if [ -z $AUTH0_SUBDOMAIN ]; then
  echo "You must define a auth0 subdomain."
  exit 1
fi

# add aliases to profile and install helm
source .profile

# Create tiller, and secure it
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl --namespace=kube-system patch deployment tiller-deploy --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

# Init config
if [ -f config.yaml ]; then
  echo "config.yaml already exists. The script won't modify it."
else
  SECRET=$( openssl rand -hex 32 )
  sed "s#secretToken:.*#secretToken: ${SECRET}#g" < base_config.yaml > config.yaml
  sed -i -e "s#AUTH0_SUBDOMAIN.*#AUTH0_SUBDOMAIN: ${AUTH0_SUBDOMAIN}#g" config.yaml
  sed -i -e "s#OAUTH_CALLBACK_URL.*#OAUTH_CALLBACK_URL: https://${DOMAIN}/hub/oauth_callback#g" config.yaml
fi

# Add jupyterhub to helm
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm install jupyterhub/jupyterhub \
    --version=v$VERSION \
    --name=$NAME \
    --namespace=$NAMESPACE \
    -f config.yaml

# displa the pods and the proxy
kubectl --namespace=$NAMESPACE get pod
kubectl --namespace=$NAMESPACE get svc

echo "Jupyter hub is ready to be used"
echo "You may change the config file and the run 'helm-upgrade -n $NAMESPACE'"
