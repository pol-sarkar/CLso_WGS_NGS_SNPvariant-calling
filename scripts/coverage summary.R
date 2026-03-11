#mapping coverage summary for all files

#activate conda
conda activate bioinfo

#!/bin/bash
# Folder containing your BAM files
bam_folder="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/bam_files"

bam_folder="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/bam_files"

for bam in ${bam_folder}/*_sorted.bam; do
sample=$(basename "$bam" _sorted.bam)
avg_cov=$(samtools depth "$bam" | awk '{sum+=$3} END {if (NR>0) print sum/NR; else print 0}')
echo -e "${sample}\t${avg_cov}"
done > ${bam_folder}/coverage_summary.txt

echo "✅ Coverage summary saved to: ${bam_folder}/coverage_summary.txt"



#For mapping everything alternatively you can use this 
#!/bin/bash

#!/bin/bash

bam_dir="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/bam_files"
ref="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/Reference/ncbi_dataset/data/GCA_000183665.1/GCA_000183665.1_ASM18366v1_genomic.fna"
output="${bam_dir}/coverage_summary_detailed.txt"

# --- Get reference genome length (total number of bases) ---
GENOME_LEN=$(grep -v ">" "$ref" | tr -d '\n' | wc -c)
echo "Reference genome length = $GENOME_LEN bp"

echo -e "Sample\tAverage_Coverage\tPercent_Genome_Covered(>1x)" > "$output"

for bam in ${bam_dir}/*_sorted.bam; do
sample=$(basename "$bam" _sorted.bam)

# Check if BAM exists and is not empty
if [[ ! -s "$bam" ]]; then
echo -e "${sample}\t0\t0" | tee -a "$output"
continue
fi

# Check if BAM index exists, if not create it
if [[ ! -f "${bam}.bai" ]]; then
echo "Indexing $bam ..."
samtools index "$bam"
fi

# Get number of mapped reads
mapped_reads=$(samtools view -c -F 260 "$bam")

# If no mapped reads → zero coverage
if [[ $mapped_reads -eq 0 ]]; then
echo -e "${sample}\t0\t0" | tee -a "$output"
continue
fi

# Calculate average coverage
avg_cov=$(samtools depth "$bam" | awk '{sum+=$3} END {if (NR>0) print sum/NR; else print 0}')

# Calculate percent of genome covered at >1×
percent_cov=$(samtools depth "$bam" | awk -v L=$GENOME_LEN '{if($3>=1) covered++} END {if (L>0) print (covered/L)*100; else print 0}')

echo -e "${sample}\t${avg_cov}\t${percent_cov}" | tee -a "$output"
done

echo "✅ Coverage details saved to: $output"
