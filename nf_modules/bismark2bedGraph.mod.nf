nextflow.enable.dsl=2

// parameters passed in by specialised pipelines
params.dirty_harry = false
params.save_intermediate = false

process BISMARK2BEDGRAPH {
	
	tag "$name" // Adds name to job submission instead of (1), (2) etc.

	conda '/users/thomas.ellis/nextflow_pipelines_rp/environment.yml'
	// conda (params.enable_conda ? "bioconda::bismark=0.23.0" : null)
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/bismark:0.23.0--0' :
    //     'quay.io/biocontainers/bismark:0.23.0--0' }"

	label 'bigMem' // 20G
			
    input:
	    tuple val (name), path(reads)
		val (outputdir)
		val (bismark2bedGraph_args)
		val (verbose)

	output:
	    path "*cov.gz",        emit: coverage
		path "*bedGraph.gz",   emit: bedGraph
		
	publishDir "$outputdir",
		mode: "copy", overwrite: true,
		saveAs: {filename ->
			if( params.save_intermediate ) filename
			else null
		}

    script:

		if (verbose){
			println ("[MODULE] BISMARK2BEDGRAPH ARGS: " + bismark2bedGraph_args)
		}

		// Options we add are
		bismark2bedGraph_options = bismark2bedGraph_args

		if (params.dirty_harry){
			output_name = name + "_DH.bedGraph.gz"  // Dirty Harry
		} 
		else{
			output_name = name + ".bedGraph.gz"
		}
		// println ("Output name: $output_name")
		// println ("Input names: $reads")
		
		all_reads = reads

		"""
		bismark2bedGraph --buffer 15G -o $output_name $bismark2bedGraph_options $all_reads
		"""
		
}