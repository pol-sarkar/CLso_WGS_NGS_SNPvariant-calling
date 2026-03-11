#!/bin/bash

# Folder containing BAM files
bam_folder="/rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/bam_files/"

# Reference genome length (update this to match your Liberibacter reference)
GENOME_LEN=1250000  

# Output summary file
summary_file="${bam_folder}coverage_summary.txt"
echo -e "Sample\tTotalBases\tBases1x\tBases5x\tBases10x\tBases20x\tCoveredPositions" > "$summary_file"

# Loop over all sorted BAM files
for bam in "${bam_folder}"*_sorted.bam; do
    sample=$(basename "$bam" "_sorted.bam")
    echo "Processing $sample ..."

    # Depth file
    DEPTH_FILE="${bam_folder}${sample}_coverage.txt"

    # Generate depth file if it does not exist
    if [ ! -f "$DEPTH_FILE" ]; then
        samtools depth "$bam" > "$DEPTH_FILE"
    fi

    # Calculate coverage statistics
    read sum c1 c5 c10 c20 pos_cov <<< $(awk -v L=$GENOME_LEN '{
          sum += $3;
          if($3>0) pos++;
          if($3>=1) c1++;
          if($3>=5) c5++;
          if($3>=10) c10++;
          if($3>=20) c20++;
      } END{
         printf "%d %d %d %d %d %d", sum, (c1+0), (c5+0), (c10+0), (c20+0), (pos+0)
      }' "$DEPTH_FILE")

    # Append results to summary file
    echo -e "${sample}\t${sum}\t${c1}\t${c5}\t${c10}\t${c20}\t${pos_cov}" >> "$summary_file"
done

echo "All samples processed. Summary saved to $summary_file"

