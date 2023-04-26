#!/bin/bash -x
export MYIP=$(curl 2ip.ru)
kubectl apply -f  cluster-issuer.yaml  

for f in ./*.tmpl; do 
  echo "===========Processing $f file.================="; 
  cat $f|envsubst|tee  "${f%.*}"
  kubectl  apply -f  "${f%.*}"
  rm -f  "${f%.*}"
done
