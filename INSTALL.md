# Installing Droneshare

This document is mostly assuming you are installing to the 3DR version of droneshare.  If you are forking droneshare for your own purposes, then some of these commands may need your personal credentials.

Droneshare is (currently) an entirely Angular client side application.  So deployment is mostly a matter of finding a suitable static file server.

## Installing to Appengine

See deploy-to-appengine.sh for example.

## Installing to Amazon S3

* pip install awscli
* aws configure - and then enter your AWS credentials
* Configure aws per http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
* complete -C aws_completer aws
* deploy-to-s3.sh
