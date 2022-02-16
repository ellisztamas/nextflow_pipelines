nextflow.enable.dsl=2

params.singlecell = false
params.rrbs       = false
params.verbose    = false
params.pbat       = false
params.nonCG      = true

process BISMARK_METHYLATION_EXTRACTOR {
	label 'bigMem'          // 20G
	label 'quadCore'        // 4 cores
	
	tag "$name" // Adds name to job submission instead of (1), (2) etc.

	conda (params.enable_conda ? "bioconda::bismark=0.23.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bismark:0.23.0--0' :
        'quay.io/biocontainers/bismark:0.23.0--0' }"

    input:
	    tuple val (name), path(bam)
		val (outputdir)
		val (bismark_methylation_extractor_args)
		val (verbose)

	output:
	    tuple val (name), path ("CpG*"),        emit: context_files_CG
		path "CH*",                             emit: context_files_nonCG
		path "*report.txt",                     emit: report
		path "*M-bias.txt",                     emit: mbias
		path "*cov.gz",                         emit: coverage
	
	publishDir "$outputdir",
		mode: "copy", overwrite: true
    
	script:
		
		if (verbose){
			println ("[MODULE] BISMARK METHYLATION EXTRACTOR ARGS: " + bismark_methylation_extractor_args)
		}


		// Options we add are
		methXtract_options = bismark_methylation_extractor_args + " --gzip "
		
		if (params.singlecell){
			// println ("FLAG SINGLE CELL SPECIFIED: PROCESSING ACCORDINGLY")
		}

		if (params.nonCG){
			if (verbose){
				println ("FLAG nonCG specified: adding flag --CX ")
			}
			methXtract_options +=  " --CX "
		}

		isPE = isPairedEnd(bam)
		if (isPE){
			// not perform any ignoring behaviour for RRBS or single-cell libraries
			if (!params.rrbs && !params.singlecell && !params.pbat){
				// default ignore parameters for paired-end libraries
				methXtract_options +=  " --ignore_r2 2 "
			}
		}
		else{
			// println("File seems to be single-end")
		}

		// println ("Now running command: bismark_methylation_extractor -parallel ${cores} ${methXtract_options} ${bam}")
		"""
		bismark_methylation_extractor --bedGraph --buffer 10G -parallel $task.cpus ${methXtract_options} ${bam}
		"""

}


def isPairedEnd(bamfile) {

	// need to transform the nextflow.processor.TaskPath object to String
	bamfile = bamfile.toString()
	if (params.verbose){
		println ("Processing file: " + bamfile)
	}
	
	if (bamfile =~ /_pe/){
		if (params.verbose){
			println ("File is paired-end!")
		}
		return true
	}
	else{
	 	if (params.verbose){
			 println ("File is single-end")
		 }
		return false
	}
}