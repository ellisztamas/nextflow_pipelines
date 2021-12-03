nextflow.enable.dsl=2

process SAMTOOLS_SORT{	
    
	tag "$bam" // Adds name to job submission instead of (1), (2) etc.
	label 'bigMem' // 20GB

	conda (params.enable_conda ? "bioconda::samtools=1.14" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.14--hb421002_0' :
        'quay.io/biocontainers/samtools:1.14--hb421002_0' }"


	input:
		path(bam)
		val (outputdir)
		val (samtools_sort_args)
		val (verbose)

	output:
		// path "*report.txt", emit: report
		path "*bam",        emit: bam

	publishDir "$outputdir",
		mode: "link", overwrite: true

	
    script:
		samtools_sort_options = samtools_sort_args
		
		if (verbose){
			println ("[MODULE] SAMTOOLS SORT ARGS: " + samtools_sort_args)
		}
		
		// TODO: Find more elegant way to strip file ending of input BAM file

		"""
		samtools sort $samtools_sort_options $bam -o ${bam}_sorted.bam 
		rename .bam_sorted _sorted *
    	"""
		
	
}

process SAMTOOLS_INDEX{	
    
	tag "$bam"     // Adds name to job submission instead of (1), (2) etc.
	label 'bigMem' // 20GB

	conda (params.enable_conda ? "bioconda::samtools=1.14" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.14--hb421002_0' :
        'quay.io/biocontainers/samtools:1.14--hb421002_0' }"


	input:
		path(bam)
		val (outputdir)
		val (samtools_index_args)
		val (verbose)

	output:
		path "*.bai",     emit: bai
    	
	publishDir "$outputdir",
		mode: "copy", overwrite: true

    script:
		samtools_index_options = samtools_index_args
		
		if (verbose){
			println ("[MODULE] SAMTOOLS INDEX ARGS: " + samtools_index_args)
		}
		
		"""
		samtools index $samtools_index_options $bam
		"""
		
	
}