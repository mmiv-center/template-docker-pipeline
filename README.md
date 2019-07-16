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

### Example spreadsheet generation after cross-sectional run

In order to create a single spreadsheet with all volume, area, and
thickness measures for all participants run something like this:

```
/bin/bash

subj="-s 00001 -s 00002"
export SUBJECTS_DIR=$(pwd)
mkdir Measures

aparcstats2table --hemi rh ${subj} --parc aparc.a2009s --report-rois True --meas area -t Measures/aparc_a2009s_rh_area.txt
aparcstats2table --hemi lh ${subj} --parc aparc.a2009s --report-rois True --meas area -t Measures/aparc_a2009s_lh_area.txt
aparcstats2table --hemi rh ${subj} --parc aparc.a2009s --report-rois True --meas volume -t Measures/aparc_a2009s_rh_volume.txt
aparcstats2table --hemi lh ${subj} --parc aparc.a2009s --report-rois True --meas volume -t Measures/aparc_a2009s_lh_volume.txt
aparcstats2table --hemi rh ${subj} --parc aparc.a2009s --report-rois True --meas thickness -t Measures/aparc_a2009s_rh_thickness.txt
aparcstats2table --hemi lh ${subj} --parc aparc.a2009s --report-rois True --meas thickness -t Measures/aparc_a2009s_lh_thickness.txt
aparcstats2table --hemi rh ${subj} --parc aparc.a2009s --report-rois True --meas foldind -t Measures/aparc_a2009s_rh_foldind.txt
aparcstats2table --hemi lh ${subj} --parc aparc.a2009s --report-rois True --meas foldind -t Measures/aparc_a2009s_lh_foldind.txt

aparcstats2table --hemi rh ${subj} --parc aparc --meas area -t Measures/aparc_desikan_rh_area.txt
aparcstats2table --hemi lh ${subj} --parc aparc --meas area -t Measures/aparc_desikan_lh_area.txt
aparcstats2table --hemi rh ${subj} --parc aparc --meas volume -t Measures/aparc_desikan_rh_volume.txt
aparcstats2table --hemi lh ${subj} --parc aparc --meas volume -t Measures/aparc_desikan_lh_volume.txt
aparcstats2table --hemi rh ${subj} --parc aparc --meas thickness -t Measures/aparc_desikan_rh_thickness.txt
aparcstats2table --hemi lh ${subj} --parc aparc --meas thickness -t Measures/aparc_desikan_lh_thickness.txt

asegstats2table ${subj} --meas volume --all-segs -t Measures/aseg_volume.txt
asegstats2table ${subj} --meas mean --all-segs -t Measures/aseg_mean_intensity.txt
```

Afterwards merge all the spreadsheets in Measures into a single spreadsheet using R:
```
> cd Measures
> R
files = Sys.glob("*.txt")
data = data.frame(src_subject_id=NA)
for (i in files) {
    print(i)
    d = read.table(i, header=TRUE, sep="\t")
    if (i == "aseg_volume.txt") {
       nn = names(d)
       for (j in seq(2,length(nn))) {
       	  nn[j] = paste(nn[j], "_vol", sep="")
       }
       names(d) = nn
    }
    if (i == "aseg_mean_intensity.txt") {
       nn = names(d)
       for (j in seq(2,length(nn))) {
       	  nn[j] = paste(nn[j], "_mean_intensity", sep="")
       }
       names(d) = nn
    }    
    data = merge(data, d, by.x=names(data)[[1]], by.y=names(d)[[1]], all.x=T, all.y=T)
}
write.csv(data,file="Measures.csv",row.names=F)
```

The resulting Measures.csv file will contain one row for each participant with the measures as columns.
