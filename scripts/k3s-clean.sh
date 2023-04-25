#!/bin/sh
systemctl stop k3s
rm -rf /var/lib/rancher/k3s
systemctl start k3s

