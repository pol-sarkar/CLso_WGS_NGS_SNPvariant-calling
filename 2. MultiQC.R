#go to working directory
cd ~/shared/labprojects/WGS-Liberibacter-Pol/trimmed

#create the slurm
nano multiqc.slurm

#QC Visualization (MultiQC)
#Make a new SLURM script — multiqc.slurm:
#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --output=multiqc_%j.log
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --partition=epyc

module load multiqc/1.14  # or use your conda env if available

cd ~/shared/labprojects/WGS-Liberibacter-Pol/trimmed

multiqc . -o ../multiqc_report

echo "MultiQC report generation completed!"



# check available version with 'module avail multiqc'
module load multiqc/1.13  

#if not, download miniconda:
cd ~
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#Install it to your home folder
bash Miniconda3-latest-Linux-x86_64.sh

#run
source ~/.bashrc
#Create the MultiQC environment:
conda create -n multiqc_env python=3.10 multiqc -y
conda activate multiqc_env


#submit it
sbatch multiqc.slurm

#or if you are running in multiqc_env:
cd /rhome/poulamis/shared/labprojects/WGS-Liberibacter-Pol/trimmed/
  multiqc .


#After it finishes:
Go to trimmed/multiqc_report/
  
  Download the .html file and open it in your browser — that’s your overall QC summary across all samples.