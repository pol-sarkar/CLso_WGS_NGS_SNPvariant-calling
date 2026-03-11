Run this to make sure all 20 pairs are there:
  cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol

Submit the trimming job:
  sbatch trim_fastp.slurm


ls *_R1_001.fastq.gz | wc -l

And

ls *_R2_001.fastq.gz | wc -l



Check if fastp is available on Skylark
module avail fastp
(if available: you should see smth : fastp/0.23.2
  
  , or , you will have to install it via conda)

Load it:
  module load fastp/0.23.2





2. Create an output directory
mkdir -p /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed




3. Create a Slurm script
nano /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trim_fastp.slurm




4. Paste this exact code inside:
  
  #!/bin/bash
  #SBATCH --job-name=fastp_trim
  #SBATCH --output=fastp_trim_%j.log
  #SBATCH --time=04:00:00
  #SBATCH --cpus-per-task=4
  #SBATCH --mem=8G
  
  module load fastp

RAW_DIR=/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol
OUT_DIR=${RAW_DIR}/trimmed

mkdir -p $OUT_DIR

for R1 in ${RAW_DIR}/*_R1_001.fastq.gz
do
SAMPLE=$(basename $R1 _R1_001.fastq.gz)
R2=${RAW_DIR}/${SAMPLE}_R2_001.fastq.gz

echo "Processing sample: $SAMPLE"

fastp \
-i $R1 \
-I $R2 \
-o ${OUT_DIR}/${SAMPLE}_R1_trimmed.fastq.gz \
-O ${OUT_DIR}/${SAMPLE}_R2_trimmed.fastq.gz \
-h ${OUT_DIR}/${SAMPLE}_fastp.html \
-j ${OUT_DIR}/${SAMPLE}_fastp.json \
--detect_adapter_for_pe \
--length_required 50 \
--cut_mean_quality 20 \
--thread 4
done




To save and exit: Ctrl + O  →  Enter  →  Ctrl + X



Press Ctrl + O (that’s the letter O, not zero)
→ it’ll say: File Name to Write:
  → just press Enter to confirm.

Then press Ctrl + X to exit nano.
5. Submit the job
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol
sbatch trim_fastq.slurm


OR

sbatch trim_fastq.slurm


OR, if you want to submit the manifest file all together:
  
  #!/bin/bash
  #SBATCH --job-name=fastp_trim
  #SBATCH --output=fastp_trim_%j.log
  #SBATCH --error=fastp_trim_%j.log
  #SBATCH --partition=epyc
  #SBATCH --time=04:00:00
  #SBATCH --mem=8G
  #SBATCH --cpus-per-task=4
  
  module load fastp/0.23.2

INPUT_DIR=/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol
OUTPUT_DIR=$INPUT_DIR/trimmed

mkdir -p $OUTPUT_DIR

for R1 in ${INPUT_DIR}/*_R1_001.fastq.gz; do
base=$(basename $R1 _R1_001.fastq.gz)
R2=${INPUT_DIR}/${base}_R2_001.fastq.gz

fastp \
-i $R1 \
-I $R2 \
-o ${OUTPUT_DIR}/${base}_R1_trimmed.fastq.gz \
-O ${OUTPUT_DIR}/${base}_R2_trimmed.fastq.gz \
--cut_front --cut_tail \
--cut_mean_quality=20 \
--length_required=50 \
--detect_adapter_for_pe \
-w 4 \
-h ${OUTPUT_DIR}/${base}_fastp.html \
-j ${OUTPUT_DIR}/${base}_fastp.json
done



Then in the terminal run:
  
  cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol
sbatch trim_fastp.slurm

Or 
sbatch -a 4-21 trim_fastp.slurm




You should see something like this: 
  Submitted batch job ######

6. Monitor the job

squeue -u poulamis

When you finish, your job will be in : /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/
  
  
  tail -f fastp_trim_20370892.log

#to check if your
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed
# 1️⃣ Check how many trimmed files were generated
ls *_trimmed.fastq.gz | wc -l

# 2️⃣ Check file sizes (make sure none are 0 bytes)
ls -lh *_trimmed.fastq.gz | head

# 3️⃣ Optional: peek into one fastp report
ls *.html | head

#next steps you can do to confirm quality and prepare for the next stage
ls -lh *.html

#Check read counts (optional):
zcat A_S1_R1_trimmed.fastq.gz | wc -l | awk '{print $1/4}'

zcat A_S1_R2_trimmed.fastq.gz | wc -l | awk '{print $1/4}'


or 
#quickly check all your trimmed FASTQ files and make sure the read counts match for each pair
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed

cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed

for R1 in *_R1_trimmed.fastq.gz; do
base=${R1%_R1_trimmed.fastq.gz}
R2=${base}_R2_trimmed.fastq.gz

# Count reads (lines / 4)
count_R1=$(zcat "$R1" | wc -l | awk '{print $1/4}')
count_R2=$(zcat "$R2" | wc -l | awk '{print $1/4}')

# Print results
echo -e "$base\tR1: $count_R1\tR2: $count_R2"
done



