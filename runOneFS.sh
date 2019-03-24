#!/bin/bash

fn=$1
fnpath=`realpath ${fn%%1.dcm}`
dn=$(echo "$fn" | cut -d'/' -f1)
subject=${dn}
od=${dn}/fsurf/

echo "generate output in ${od}"
if [ ! -d "${od}" ]; then
    mkdir -p ${od}
fi
od=`realpath ${od}`

# run recon-all if the stats file does not exist yet
#if [ ! -f "${od}/${subject}/stats/aseg.stats" ]; then
#    echo "file does not exists: ${od}/${subject}/stats/aseg.stats"
#fi

# generate a name for the container so we can wait for it to finish here
UUID=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | head -c 8)

if [ ! -f "${od}/${subject}/stats/aseg.stats" ]; then
    docker run --rm --name ${UUID} -v ${fnpath}:/input -v ${od}:/output fs60 /bin/bash -c "recon-all -i /input/1.dcm -subjid ${subject} -all"
    status_code="$(docker container wait ${UUID})"
fi
# run the hippocampus and amygdala subfields
if [ -f "${od}/${subject}/stats/aseg.stats" ]; then
    docker run --rm --name ${UUID} -v ${od}:/output fs60beta /bin/bash -c "segmentHA_T1.sh ${subject}"
    status_code="$(docker container wait ${UUID})"
fi
