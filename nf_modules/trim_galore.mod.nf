nextflow.enable.dsl=2

params.singlecell = ''
params.rrbs       = ''
params.pbat       = ''
params.clock      = false
params.single_end = false
// For Epigenetic Clock Processing
params.three_prime_clip_R1 = ''
params.three_prime_clip_R2 = ''


process TRIM_GALORE {	
    
	tag "$name"                         // Adds name to job submission instead of (1), (2) etc.

	label 'quadCore'                    // sets cpus = 4

	conda (params.enable_conda ? 'bioconda::trim-galore=0.6.7' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trim-galore:0.6.7--hdfd78af_0' :
        'quay.io/biocontainers/trim-galore:0.6.7--hdfd78af_0' }"
	
	// dynamic directive
	memory { 10.GB * task.attempt }  
	maxRetries 2
    
	input:
	    tuple val (name), path (reads)
		val (outputdir)
		val (trim_galore_args)
		val (verbose)

	output:
	    tuple val(name), path ("*fq"), emit: reads
		path "*trimming_report.txt", optional: true, emit: report
		
	publishDir "$outputdir",
		mode: "copy", overwrite: true


    script:
		if (verbose){
			println ("[MODULE] TRIM GALORE ARGS: " + trim_galore_args)
		}
		
		pairedString = ""
		if (params.single_end){
			// paired-end mode may be overridden, see e.g. TrAEL-seq Indexing
		}
		else{
			if (reads instanceof List) {
				pairedString = "--paired"
			}
		}

		// Specialised Epigenetic Clock Processing		
		if (params.clock){
			trim_galore_args += " --breitling "	
		}
		else{
			if (params.singlecell){
				trim_galore_args += " --clip_r1 6 "
				if (pairedString == "--paired"){
					trim_galore_args += " --clip_r2 6 "
				}
			}

			if (params.rrbs){
				trim_galore_args = trim_galore_args + " --rrbs "
			}
			
			if  (params.pbat){
				trim_galore_args = trim_galore_args + " --clip_r1 $params.pbat "
				if (pairedString == "--paired"){
					trim_galore_args = trim_galore_args + " --clip_r2 $params.pbat "
				}
			}

			// Second step of Clock processing:
			if (params.three_prime_clip_R1 && params.three_prime_clip_R2){
				trim_galore_args +=	" --three_prime_clip_R1 ${params.three_prime_clip_R1} --three_prime_clip_R2 ${params.three_prime_clip_R2} "
			}
		}

		"""
		trim_galore $trim_galore_args ${pairedString} ${reads}
		"""

}