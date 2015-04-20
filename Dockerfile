# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
#FROM phusion/passenger-full:latest
# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby19:<VERSION>
#FROM phusion/passenger-ruby20:<VERSION>
#FROM phusion/passenger-ruby21:<VERSION>
#FROM phusion/passenger-ruby22:latest
#FROM phusion/passenger-jruby17:<VERSION>
#FROM phusion/passenger-nodejs:latest
FROM phusion/passenger-customizable:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
#CMD ["/sbin/my_init", "--", "bundle", "exec", "thin", "start"]
CMD ["/sbin/my_init"]
# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
RUN /pd_build/utilities.sh
#   Ruby support.
#RUN /pd_build/ruby1.9.sh
#RUN /pd_build/ruby2.0.sh
#RUN /pd_build/ruby2.1.sh
RUN /pd_build/ruby2.2.sh
#RUN /pd_build/jruby1.7.sh
#   Python support.
#RUN /pd_build/python.sh
#   Node.js and Meteor support.
RUN /pd_build/nodejs.sh

# ...put your own build instructions here...
RUN npm install bower -g
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN usermod -a -G sudo app
USER app
RUN mkdir -p /home/app/webapp
RUN sudo -u app -H git clone -b lms https://0425f933fa963abb745bfaf637f906e52572d3aa:x-oauth-basic@github.com/afterclassroom/go_to_classroom.git /home/app/webapp/go_to_classroom
ADD database.yml /home/app/webapp/go_to_classroom/config/database.yml
ADD s3.yml /home/app/webapp/go_to_classroom/config/s3.yml
RUN chmod -R g+w /home/app/webapp/go_to_classroom/log
WORKDIR /home/app/webapp/go_to_classroom
RUN sudo -u app -H bundle config build.nokogiri --use-system-libraries
RUN sudo -u app -H bundle install --path vendor/bundle
RUN rake tmp:cache:clear
USER root
#ADD secret_key.conf /etc/nginx/main.d/secret_key.conf
#ADD gzip_max.conf /etc/nginx/conf.d/gzip_max.conf
#ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf
#RUN rm -f /etc/service/redis/down
#RUN rm -f /etc/service/memcached/down
# RUN mkdir /etc/service/memcached
#ADD memcached.sh /etc/service/memcached/run

# Ruby 1.9.3 (you can ignore the "1.9.1" suffix)
#RUN ruby-switch --set ruby1.9.1
# Ruby 2.0
#RUN ruby-switch --set ruby2.0
# Ruby 2.1
#RUN ruby-switch --set ruby2.1
# Ruby 2.2
RUN ruby-switch --set ruby2.2
# JRuby
#RUN ruby-switch --set jruby

#RUN mkdir -p /etc/my_init.d
#ADD logtime.sh /etc/my_init.d/logtime.sh

#RUN apt-get update && apt-get upgrade

RUN rm -f /etc/service/sshd/down
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
# Clean up APT when done.
EXPOSE 3000
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
