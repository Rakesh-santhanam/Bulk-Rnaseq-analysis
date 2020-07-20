## download expression data from gene omni bus
## https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE147507 
# https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA615032&f=cell_line_sam_ss_dpl110_ss%3An%3Aa549%3Ac%3Bstrain_sam_ss%3An&o=acc_s%3Aa

## select interested strains and cell line
## for this tutorial a549 cell lines are selected
## export csv format table to download files
## four runs one sample
cat a549_meta_table_1.csv | awk -F, '{print $4}' | sed '/Run/d' > srr_samples.txt

mv /home/rocky/ncbi/public/sra/*sra .

cat srr_samples.txt | xargs -I{} -n1 fastq-dump --gzip --defline-qual '+' --split-files {}.sra

## run fastqc                                                                   
mkdir fastqc
ls -1 *.gz | xargs -I{} -n1 -P 5 fastqc {} -o fastqc_output ###  

multiqc fastqc_output/ ## multiqc needs output folder of fastqc report (for example fastqc_output)
## good explanation about multiqc in lockdown-learning bioinformatics-org #18 lockdown learning bioinformaticd along
## good explanation about rnaseq history and which databases to use for mapping  in lockdown-learning bioinformatics-org #19 lockdown learning bioinformaticd along

## lot of gymnastic has to be done to prepare salmon_run.txt because four fastq files contributes to one samples
cat salmon_run.txt | xargs -I{} -n1 sh -c {}

## after sucessful run each folder has quant.sf files which has qunatification and also other details such as gene or transcript length
## after salmon_quant- everything is in R                                       
## tximport function in r converts transript abundance to gene counts           
                                                                                
## for tximport we need gene_name and corresponding transcript name as dataframe
grep '>' gencode.v34.transcripts.fa | awk -F"\|" '{print $1}' | awk -F"\>" '{print $2}' | awk -F"." '{print $1}' > enst.txt

# ensg files                                                                    
grep '>' gencode.v34.transcripts.fa | awk -F"\|" '{print $2}' | awk -F"." '{print $1}' > ensg.txt

## sanity check number of lines                                                 
wc -l ens* ## has to be equal                                                   
paste -d ',' enst.txt ensg.txt > gene_map.csv ## pasting columns 
