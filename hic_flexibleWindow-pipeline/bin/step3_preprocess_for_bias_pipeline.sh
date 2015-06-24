#!/bin/bash

# step 3 operations:
# preprocess the genome to get mappability per window. Note: needs to be run only once for a particular resolution

# argument list: 1:<project directory> 
#                2:<path to python> 
#                3:<path to preprocessedForBias directory>
#                4:<resolution/window size>          
#                5:<org - argument used for naming the folders>
#                6:<ref - argument used for naming the folders>
#                7:<RE - argument used for naming the folders>
#                8:<file with HindIII restriction enzyme fragments>
#                9:<file with chromosome sizes>
#

PROJDIR=$1
python=$2
biasdir=$3
w=$4
org=$5
ref=$6
REsites=$7
readlen=$8 # length of the read
RE=$9
#example settings
#PROJDIR=/srv/gsfs0/projects/kundaje/users/mtaranov/projects/dynamic3D/FIT-HI-C/hic_pipeline
#python=/srv/gs1/software/python/python-2.7/bin/python
#biasdir=$PROJDIR/data/preprocessedForBias
#w=40000
#org=human
#ref=ENCODEhg19Male
#RE=HindIII
#REfile=/srv/gsfs0/projects/kundaje/users/oursu/LongRangeInteractionPrediction/data/HICUP_genomes/Digest_ENCODEHg19_HindIII_None_19-38-29_25-11-2014.txt
#chrSizes=/srv/gs1/projects/kundaje/oursu/Alignment/data/ENCODE_genomes/male/ref.fa.fai
#readlen=50
#bedtools=/srv/gs1/software/bedtools/2.21.0/bin/bedtools

mkdir -p $biasdir

jobfile=$PROJDIR/pipeline/step3-createWindowMappability_RE${w}

echo "$python $PROJDIR/bin/mappability_from_bed.py --regions $REsites --read_length ${readlen} --out ${biasdir}/${org}-${ref}.${RE}.RE${w}" >> $jobfile

chmod 777 $jobfile
qsub -l h_vmem=20G -l h_rt=4:00:00 -m ea  -M taranova.maryna@gmail.com -o $PROJDIR/pipeline/o.step3_RE${w}_out -e $PROJDIR/pipeline/e.step3_RE${w}_error ${jobfile}
## the output files will have 4 fields:
## <chr> <mid> <RE site> <mappability> <GC content>
# Output will look like ${biasdir}/human-hg19.HindIII.w40000
