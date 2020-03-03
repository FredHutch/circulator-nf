#!/usr/bin/env nextflow

// Function which prints help message text
def helpMessage() {
    log.info"""
    Usage:

    nextflow run FredHutch/circulator-nf <ARGUMENTS>
    
    Required Arguments:
      --input_fasta         Path to FASTA files to analyze (example: input_folder/*.fasta.gz)
      --output_folder       Folder to place analysis outputs

    """.stripIndent()
}

// Show help message if the user specifies the --help flag at runtime
params.help = false
if (params.help || params.input_fasta == null || params.output_folder == null){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 1
}

