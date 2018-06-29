#!/bin/bash

ARGS=""
while [ ! -z $1 ]; do
  case $1 in
    -v | --version) VERSION=$2; shift 2;;
    -n | --namespace) NAMESPACE=$2; shift 2;;
    -i | --image) IMAGE=$2; shift 2;;
    *) ARGS="${ARGS}$1 "; shift 1;;
  esac
done

if [ -z $NAMESPACE ]; then
  echo "You must define a namespace."
  exit 1
fi
if [ -z $VERSION ]; then
  echo "You must define a version."
  exit 1
fi
if [ -z $IMAGE ]; then
  echo "You must define an image."
  exit 1
fi

CMD="helm upgrade $NAMESPACE $IMAGE --version=v$VERSION"
if [ -f config.yaml ]; then
  CMD="$CMD -f config.yaml"
fi
echo "Run: $CMD $ARGS"
eval "$CMD $ARGS"
