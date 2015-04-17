#!/bin/bash
# Install LMS script

sudo apt-get update

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' docker|grep -c "ok installed")
echo Checking for docker: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "No docker. Install docker."
  wget -qO- https://get.docker.com/ | sh
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' fig|grep -c "ok installed")
echo Checking for fig: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "No fig. Install fig."
  curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /usr/local/bin/fig; chmod +x /usr/local/bin/fig
fi

fig build  --no-cache

fig up -d

fig run web rake db:migrate 
fig run web sudo -u app -H rake RAILS_ENV=production assets:precompile

