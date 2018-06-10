#!/bin/bash
set -x

source /assets/bin/entrypoint.functions

remove-ipv6-from-hostsfile

# start jenkins
#!!!check this in next build (add script to entrypoint.functions)
source /usr/local/bin/jenkins.sh
