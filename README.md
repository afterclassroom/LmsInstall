Lms Install
===================


Script for install Lms

----------


Get Lms install script
-------------

    $ sudo git clone https://github.com/afterclassroom/lms_install.git

Install
-------------

   

    $ cd lms_install

> Edit file webapp.conf change domain www.pesome.com with your Lms domain

> Insert Amazon S3 to file s3.yml

Run file install.sh

    $ sudo chmod +x install.sh
    $ sudo ./install.sh
    $ fig ps
    $ docker-enter root_web_1
    $ cd /home/app/webapp/go_to_classroom
    $ sudo -u app -H rake RAILS_ENV=production db:migrate assets:precompile
    $ exit
