
cd /bigdata/maucklab/shared/labprojects/WGS-Liberibacter-Pol/bam

echo -e "Sample\tAvgDepth\tMappedPairs_Q30_NoDup_PrimaryProper" > mapping_depth_summary.tsv

while read -r bam; do
sample="${bam%.markdup.bam}"

echo "Processing $sample ..." >&2

# Average depth across reference (includes zero-coverage positions)
avgDepth=$(samtools depth -a "$bam" 2>/dev/null | awk '{sum+=$3; n++} END{ if(n>0) printf "%.2f", sum/n; else printf "0.00"}')

# Count UNIQUE read names for properly-paired, primary, mapped, non-duplicate, MAPQ>=30
mappedPairs=$(samtools view -q 30 -f 2 -F 3332 "$bam" 2>/dev/null | awk '{print $1}' | sort -u | wc -l)

echo -e "${sample}\t${avgDepth}\t${mappedPairs}" >> mapping_depth_summary.tsv

done < bam_markdup.list


#confirm
wc -l mapping_depth_summary.tsv
column -t mapping_depth_summary.tsv | head


----------------------------
  
  #Total reads in BAM (includes unmapped)
  samtools view -c A_S1.markdup.bam
# Mapped reads
samtools view -c -F 4 A_S1.markdup.bam
#Hihgh quality mapped reads (not pairs)
samtools view -c -q 30 -F 4 A_S1.markdup.bam
# high quality mapped pairs
samtools view -q 30 -f 2 -F 3332 A_S1.markdup.bam | awk '{print $1}' | sort -u | wc -l
