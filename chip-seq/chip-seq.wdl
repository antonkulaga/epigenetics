version development
# production configuration
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/common/files.wdl" as files
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/align/align_runs.wdl" as runs_aligner

workflow chip_seq {
    input {
        Array[String] treatments
        Array[String] controls
        String format = "AUTO"
        Boolean broad
        String destination
        String title
        File reference
        File? reference_index
        String key = "0a1d74f32382b8a154acacc3a024bdce3709"
        Int extract_threads = 12
        Int max_memory_gb = 42
        Int align_threads = 12
        Int sort_threads = 12
        Boolean copy_extracted = true
        Boolean copy_cleaned = true
        Boolean aspera_download = true
        Boolean skip_technical = true
        Boolean original_names = false
        String sequence_aligner = "minimap2"
        Boolean deep_folder_structure = true
        Boolean markdup = false
        Int compression = 9
    }

    call runs_aligner.align_runs as align_controls{
        input:
            title = title + "_controls",
            runs = controls,
            experiment_folder = destination,
            reference = reference,
            reference_index = reference_index,
            key = key,
            extract_threads = extract_threads,
            max_memory_gb = max_memory_gb,
            align_threads = align_threads,
            sort_threads = sort_threads,
            copy_cleaned = copy_cleaned,
            copy_extracted = copy_extracted,
            aspera_download = aspera_download,
            skip_technical = skip_technical,
            original_names = original_names,
            sequence_aligner = sequence_aligner,
            markdup = markdup,
            compression = compression
    }


    call runs_aligner.align_runs as align_treatments{
        input:
            title = title + "_treatments",
            runs = treatments,
            experiment_folder = destination,
            reference = reference,
            reference_index = reference_index,
            key = key,
            extract_threads = extract_threads,
            max_memory_gb = max_memory_gb,
            align_threads = align_threads,
            sort_threads = sort_threads,
            copy_cleaned = copy_cleaned,
            copy_extracted = copy_extracted,
            aspera_download = aspera_download,
            skip_technical = skip_technical,
            original_names = original_names,
            sequence_aligner = sequence_aligner,
            markdup = markdup,
            compression = compression
    }

    scatter(control in align_controls.out){
        File controls_aligned = control.bam
    }

    scatter(treatment in align_treatments.out){
        File treatments_aligned = treatment.bam
    }

    call files.copy as copy_control_aligned {
        input: files = controls_aligned, destination = destination + "/" +"controls_aligned"
    }

    call files.copy as copy_treatment_aligned {
        input: files = treatments_aligned, destination = destination + "/" +"treatments_aligned"
    }


    call callpeak {
        input: control = copy_control_aligned.out,
            treatment = copy_treatment_aligned.out,
            name = title,
            format = format,
            broad = broad
    }

    call files.copy as copy_results {
        input: destination = destination, files = [callpeak.out]
    }

    output {
       File out = copy_results.out[0]
    }
}

task callpeak {
    input{
        Array[File] treatment
        Array[File] control
        String outDir = "result"
        String name
        String format = "AUTO"
        Boolean broad = true
    }

    String fixed_name = sub(name, " ", "_")

    command {
        macs2 callpeak \
        --outdir ~{outDir} \
        --treatment ~{sep=' ' treatment} \
        --control ~{sep=' ' control} \
        --name ~{fixed_name} \
        --format ~{format} ~{if(broad) then "--broad" else ""}
    }

    runtime {
        docker: "quay.io/biocontainers/macs2:2.2.7.1--py39h38f01e4_2"
        maxRetries: 2
    }

    output {
        File out   = outDir
    }

}


