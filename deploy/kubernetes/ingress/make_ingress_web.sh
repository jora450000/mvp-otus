#!/bin/bash -x
export MYIP=$(curl 2ip.ru)
kubectl apply -f  cluster-issuer.yaml  
export f=watchn.ingress.yaml.tmpl 

echo "===========Processing $f file.================="; 
cat $f|envsubst|tee  "${f%.*}"
kubectl  apply -f  "${f%.*}"
rm -f  "${f%.*}"
