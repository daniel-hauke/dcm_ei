#   This is the most basic QSUB file needed for this cluster.
#   Further examples can be found under /share/apps/examples
#   Most software is NOT in your PATH but under /share/apps
#
#   For further info please read http://hpc.cs.ucl.ac.uk
#   For cluster help email cluster-support@cs.ucl.ac.uk
#
#   NOTE hash dollar is a scheduler directive not a comment.


# These are flags you must include - Two memory and one runtime.
# Runtime is either seconds or hours:min:sec

#$ -l tmem=6G
#$ -l h_vmem=6G
#$ -l h_rt=4:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -N mmn_rec
#$ -t 1-1
#$ -o /SAN/intelsys/Psycho_Pheno2/dcm_ei/results/mmn/param_recov_rlx_glo/logfiles
#$ -e /SAN/intelsys/Psycho_Pheno2/dcm_ei/results/mmn/param_recov_rlx_glo/errorfiles
#$ -wd /SAN/intelsys/Psycho_Pheno2/dcm_ei/code/param_recov_rlx_glo

#The code you want to run now goes here.

hostname
date

echo "Current path: $PWD"
export PATH=/share/apps/matlabR2018b/bin:$PATH
echo "Execute command: precov_reinvert_cluster_rlx_glo(${SGE_TASK_ID},'MMN')" 
matlab -nodisplay -nodesktop -nojvm -nosplash -singleCompThread -r "precov_reinvert_cluster_rlx_glo(${SGE_TASK_ID},'MMN')" 

date
