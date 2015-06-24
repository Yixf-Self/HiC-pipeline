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
RE=$7
REfile=$8
chrSizes=$9

#additional variables:
readlen=50 # length of the read         
bedtools=/srv/gs1/software/bedtools/2.21.0/bin/bedtools # path to bedtools

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

jobfile=$PROJDIR/pipeline/step3-createWindowMappability_w${w}
windowfile=${biasdir}/${org}-${ref}.${RE}.w${w}_windowFile.bed

echo "$bedtools makewindows -i winnum -w ${w} -g ${chrSizes} | awk '{wend=\$4*${w}}{print \$1\"\t\"\$2\"\t\"wend}' > ${windowfile}" >> $jobfile
#intersect to count REs
#echo "cat ${REfile} | grep -v Hicup | grep -v Chromosome | cut -f1-3 | $bedtools intersect -c -a ${windowfile} -b - | sort -k1,1 -k2,2n > ${windowfile}_withNumREsites.bed" >> $jobfile
echo "cat ${REfile} | grep -v Hicup | grep -v Chromosome | grep -v chrM | cut -f1-3 | $bedtools intersect -c -a ${windowfile} -b - | sort -k1,1 -k2,2n > ${windowfile}_withNumREsites.bed" >> $jobfile

#echo "$bedtools makewindows -w ${w} -g ${chrSizes} > ${windowfile}" >> $jobfile
##intersect to count REs
#echo "cat ${REfile} | grep -v Hicup | grep -v Chromosome | cut -f1-3 | $bedtools intersect -c -a ${windowfile} -b - | $bedtools sort -chrThenSizeA -i - > ${windowfile}_withNumREsites.bed" >> $jobfile
##run mappability on the bed-like file
echo "$python $PROJDIR/bin/mappability_from_bed.py --regions ${windowfile}_withNumREsites.bed --read_length ${readlen} --out ${biasdir}/${org}-${ref}.${RE}.w${w}" >> $jobfile
echo "rm ${windowfile} ${windowfile}_withNumREsites.bed" >> $jobfile

chmod 777 $jobfile
qsub -l h_vmem=20G -m ea  -M taranova.maryna@gmail.com -o $PROJDIR/pipeline/o.step3_out -e $PROJDIR/pipeline/e.step3_error ${jobfile}
## the output files will have 4 fields:
## <chr> <mid> <RE site> <mappability> <GC content>
# Output will look like ${biasdir}/human-hg19.HindIII.w40000
