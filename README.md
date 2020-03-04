# Circulator-NF
Nextflow workflow running the Circulator tool for microbial genome assembly

For details on the Circulator tool, see [the documentation](https://sanger-pathogens.github.io/circlator/).

The algorithm and benchmarks are described in the [Genome Biology manuscript](http://www.genomebiology.com/2015/16/1/294). 
Citation: "Circlator: automated circularization of genome assemblies using long sequencing reads", 
Hunt et al, Genome Biology 2015 Dec 29;16(1):294. doi: 10.1186/s13059-015-0849-0. PMID: [26714481](http://www.ncbi.nlm.nih.gov/pubmed/?term=26714481).

```
Usage:

nextflow run FredHutch/circulator-nf <ARGUMENTS>

Required Arguments:
  --manifest            File containing the location of all input genomes and reads to process
  --output_folder       Folder to place analysis outputs

Manifest:

    The manifest is a comma-separated table (CSV) with three columns, name, fasta, and reads. For example,

    name,fasta,reads
    genomeA,assemblies/genomeA.fasta.gz,pacbio_reads/genomeA.fastq.gz
    genomeB,assemblies/genomeB.fasta.gz,pacbio_reads/genomeB.fastq.gz
```