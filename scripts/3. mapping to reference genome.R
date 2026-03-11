#go to the reference folder
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/
  
#unzip
unzip CLsoZC1.zip

#check if the fasta file is there
ls -lh

#depending on whether you want the RefSeq (GCF) or GenBank (GCA) version.
#for whole genome sequencing, choose GCA

module load bwa
module load samtools

#Index the reference genome: This only needs to be done once:

cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/
  
  bwa index ncbi_dataset/data/GCF_000183665.1/GCF_000183665.1_ASM18366v1_genomic.fna
#After indexing, you can map your trimmed FASTQs to this reference by giving the same path to BWA in your mapping script:
ref="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/ncbi_dataset/data/GCF_000183665.1/GCF_000183665.1_ASM18366v1_genomic.fna"


#Create a folder for BAM files inside trimmed:
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/
  mkdir bam_files


#Alignment and BAM generation: first go with one sample (A_S1)
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/
  
  bwa mem -t 8 /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/ncbi_dataset/data/GCF_000183665.1/GCF_000183665.1_ASM18366v1_genomic.fna \
A_S1_R1_trimmed.fastq.gz A_S1_R2_trimmed.fastq.gz | \
samtools sort -o bam_files/A_S1_sorted.bam

#Index the BAM (optional, but useful for downstream tools like IGV or variant calling)
samtools index bam_files/A_S1_sorted.bam

#Optional: Generate a BAM stats report for coverage, mapping quality, etc.:
samtools stats A_S1_sorted.bam > A_S1_sorted.stats

#BAM is ready, we can quickly check read quality, coverage, and mapping stats, with a summary check
samtools flagstat A_S1_sorted.bam
#Detailed stats with samtools stats
samtools stats A_S1_sorted.bam > A_S1_sorted.stats
##Then you can summarize coverage, insert size, mapping quality, etc. You can view a quick summary:
grep ^SN A_S1_sorted.stats
#Coverage overview with samtools depth : To see coverage across the genome:
samtools depth A_S1_sorted.bam | awk '{sum+=$3; count++} END {print "Average coverage:", sum/count}'

##to get a coverage histogram and mapping quality (MQ) plot from your BAM without loading it into IGV or R. We'll use samtools + awk + gnuplot
###Step 1: Extract coverage and MQ
# Depth across genome
samtools depth A_S1_sorted.bam > coverage.txt
# Mapping quality of each read
samtools view A_S1_sorted.bam | awk '{print $5}' > mapq.txt
##Step 2: Generate coverage histogram:Using awk to bin coverage
#!/bin/bash
#!/bin/bash

# Loop over all sorted BAM files in the folder
for bamfile in *_sorted.bam; do
echo "Processing $bamfile ..."

# Extract sample name without extension
sample=$(basename "$bamfile" "_sorted.bam")

# --- Depth across genome for this sample ---
samtools depth "$bamfile" > "${sample}_coverage.txt"

# --- Coverage histogram ---
awk '{bins[int($3/5)*5]++} END {for(i in bins) print i, bins[i]}' "${sample}_coverage.txt" | sort -n > "${sample}_coverage_hist.txt"




#to generalize this for all your other samples and to also generate coverage and mapping quality histograms and plot them for all your samples automatically


#!/bin/bash

# Folders
fastq_folder="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/"
bam_folder="${fastq_folder}bam_files/"
ref="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/ncbi_dataset/data/GCF_000183665.1/GCF_000183665.1_ASM18366v1_genomic.fna"

# Make BAM folder if it doesn't exist
mkdir -p "$bam_folder"

# Loop over all R1 trimmed FASTQ files
for fq1 in ${fastq_folder}*_R1_trimmed.fastq.gz; do
sample=$(basename "$fq1" "_R1_trimmed.fastq.gz")
fq2="${fastq_folder}${sample}_R2_trimmed.fastq.gz"

echo "Processing $sample ..."

# --- Map reads and create sorted BAM ---
bwa mem -t 8 "$ref" "$fq1" "$fq2" | samtools sort -o "${bam_folder}${sample}_sorted.bam"

# --- Index BAM ---
samtools index "${bam_folder}${sample}_sorted.bam"

# --- Generate coverage file ---
samtools depth "${bam_folder}${sample}_sorted.bam" > "${bam_folder}${sample}_coverage.txt"
awk '{bins[int($3/5)*5]++} END {for(i in bins) print i, bins[i]}' "${bam_folder}${sample}_coverage.txt" | sort -n > "${bam_folder}${sample}_coverage_hist.txt"

# --- Generate mapping quality (MQ) file ---
samtools view "${bam_folder}${sample}_sorted.bam" | awk '{print $5}' > "${bam_folder}${sample}_mapq.txt"
awk '{mq[$1]++} END {for(i in mq) print i, mq[i]}' "${bam_folder}${sample}_mapq.txt" | sort -n > "${bam_folder}${sample}_mapq_hist.txt"

# --- Plot coverage histogram ---
gnuplot << EOF
set terminal png size 800,600
set output "${bam_folder}${sample}_coverage_hist.png"
set xlabel "Coverage depth"
set ylabel "Number of positions"
set style fill solid
plot "${bam_folder}${sample}_coverage_hist.txt" using 1:2 with boxes title "Coverage"
EOF

# --- Plot mapping quality histogram ---
gnuplot << EOF
set terminal png size 800,600
set output "${bam_folder}${sample}_mapq_hist.png"
set xlabel "Mapping Quality"
set ylabel "Number of reads"
set style fill solid
plot "${bam_folder}${sample}_mapq_hist.txt" using 1:2 with boxes title "Mapping Quality"
EOF

echo "Finished $sample"
done

echo "All mapping, BAMs, and plots completed."

