#!/usr/bin/env nextflow
nextflow.preview.dsl=2


def getGenome(name) {

    return [
        name: name,
        "fasta" :  "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/",
        "bismark" : "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/",
        "bowtie2" : "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/Saccharomyces_cerevisiae.R64-1-1",
        "hisat2" : "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/Saccharomyces_cerevisiae.R64-1-1",
        "gtf" : "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/Saccharomyces_cerevisiae.R64-1-1.91.gtf",
        "hisat2_splices" : "/bi/scratch/Genomes/Yeast/Saccharomyces_cerevisiae/R64-1-1/Saccharomyces_cerevisiae.R64-1-1.91.hisat2_splices.txt"
    ]

}

