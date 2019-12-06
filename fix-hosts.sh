#!/bin/bash
set -e

IP_URL=$(< commit-trigger.txt)
IP=${IP_URL% *}
URL=${IP_URL#* }
DOMAIN=${URL#http://}
test "$IP" -a "$DOMAIN"
if [ "$DOMAIN" != "s2.stridespace.com" ]; then
  if [ "$TRAVIS" ]; then
    sudo apt-get install -qq -y --force-yes dnsmasq
    echo "listen-address=127.0.0.1" | sudo tee -a /etc/dnsmasq.conf > /dev/null 2>&1
    echo "bind-interfaces" | sudo tee -a /etc/dnsmasq.conf > /dev/null 2>&1
    echo "address=/$DOMAIN/$IP" | sudo tee -a /etc/dnsmasq.conf
    echo "user=root" | sudo tee -a /etc/dnsmasq.conf > /dev/null 2>&1
    sudo service dnsmasq restart
  elif [ "$DRONE" -o "$GITLAB_CI" ]; then
    echo $IP $DOMAIN | tee -a /etc/hosts
  else
    echo $IP $DOMAIN | sudo tee -a /etc/hosts
  fi
fi

echo $URL > testspace-url
