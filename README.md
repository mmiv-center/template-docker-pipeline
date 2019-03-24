## Example project for docker based analysis pipelines

This project can be used as a starting point for FreeSurfer
based analysis pipelines. It implements a basic analysis and
some scripts that execute the pipelines using docker in
parallel no the available hardware.

To start download a license file from the FreeSurfer webpage. Place
the license.txt file into the build-docker directory. Create the two
FreeSurfer docker containers in the build-docker directory with:

```
cd build-docker
docker build -t fs60 -f Dockerfile .
docker build -t fs60beta -f Dockerfile_beta .
```

Change the search string in the runFS.sh script to point to your
image series and adjust the number of cores (24) based on your
machine.

### Analysis pipeline

The analysis first runs a cross-sectional FreeSurfer followed by
a hippocampus subfield and amygdala subfield segmentation step. The
runOneFS.sh script implements these steps using the FreeSurfer docker
containers (see above).