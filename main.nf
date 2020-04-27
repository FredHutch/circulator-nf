#!/usr/bin/env nextflow

// Function which prints help message text
def helpMessage() {
    log.info"""
    Usage:

    nextflow run FredHutch/circulator-nf <ARGUMENTS>
    
    Required Arguments:
      --manifest            File containing the location of all input genomes and reads to process
      --output_folder       Folder to place analysis outputs

    Optional Arguments (passed directly to circlator):
      --merge_min_id        Default: 85
      --merge_breaklen      Default: 1000
      --b2r_length_cutoff   Default: 100000
      --merge_min_length_merge  Default: 4000
      --merge_reassemble_end    Default: 1000
      --merge_ref_end       Default: 15000

    Manifest:

        The manifest is a comma-separated table (CSV) with three columns, name, fasta, and reads. For example,

        name,fasta,reads
        genomeA,assemblies/genomeA.fasta.gz,pacbio_reads/genomeA.fastq.gz
        genomeB,assemblies/genomeB.fasta.gz,pacbio_reads/genomeB.fastq.gz

    """.stripIndent()
}

// Show help message if the user specifies the --help flag at runtime
params.help = false
if (params.help || params.manifest == null || params.output_folder == null){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 1
}

// Default options
params.merge_min_id = 85
params.merge_breaklen = 1000
params.b2r_length_cutoff = 100000
params.merge_min_length_merge = 4000
params.merge_reassemble_end = 1000
params.merge_ref_end = 15000

// Make sure the manifest file exists
if ( file(params.manifest).isEmpty() ){
    log.info"""
    Could not find any file named ${params.manifest}
    """.stripIndent()
}

// Parse the input FASTA files
Channel.from(
    file(
        params.manifest
    ).splitCsv(
        header: true, 
        sep: ","
    )
).ifEmpty { 
    error "Could not find any lines in ${params.manifest}" 
}.filter {
    r -> (r.name != null)
}.ifEmpty { 
    error "Could not find the 'name' header in ${params.manifest}" 
}.filter {
    r -> (r.fasta != null)
}.ifEmpty { 
    error "Could not find the 'fasta' header in ${params.manifest}" 
}.filter {
    r -> (r.reads != null)
}.ifEmpty { 
    error "Could not find the 'reads' header in ${params.manifest}" 
}.filter {
    r -> (!file(r.fasta).isEmpty())
}.ifEmpty { 
    error "Could not find the files under the 'fasta' header in ${params.manifest}" 
}.filter {
    r -> (!file(r.reads).isEmpty())
}.ifEmpty { 
    error "Could not find the files under the 'reads' header in ${params.manifest}" 
}.map {
    r -> [r["name"], file(r["fasta"]), file(r["reads"])]
}.set {
    input_ch
}

// Run Circlator
process Circlator {

  // Docker container to use
  container "quay.io/fhcrc-microbiome/circlator:latest"
  label "mem_medium"
  errorStrategy 'retry'
  maxRetries 3

  // The `publishDir` tag points to a folder in the host system where all of the output files from this folder will be placed
  publishDir "${params.output_folder}" 
  
  input:
    tuple val(name), file(fasta), file(reads) from input_ch

  // The block below points to the files inside the process working directory which will be retained as outputs (and published to the destination above)
  output:
  file "${name}/*"

"""
#!/bin/bash

set -e

# If the reads are in BAM format, convert to FASTQ
if [[ "${reads.name}" == *bam ]]; then
    samtools index ${reads}
    circlator bam2reads ${reads} reads
    READS=reads.fasta
else
    READS=${reads}
fi

df -h
echo ""
ls -lahtr
echo ""
echo "STARTING CIRCLATOR"
echo ""

circlator all \
    --threads ${task.cpus} \
    --merge_min_id ${params.merge_min_id} \
    --merge_breaklen ${params.merge_breaklen} \
    --b2r_length_cutoff ${params.b2r_length_cutoff} \
    --merge_min_length_merge ${params.merge_min_length_merge} \
    --merge_reassemble_end ${params.merge_reassemble_end} \
    --merge_ref_end ${params.merge_ref_end} \
    ${fasta} \
    \$READS \
    ${name}

"""

}
