#!/bin/bash

# input is in
files=`ls -d */1/2/1.dcm`

parallel -j 24 -I{} ./runOneFS.sh ::: $files
