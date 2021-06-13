version development
# production configuration
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/common/files.wdl" as files
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/align/align_runs.wdl" as runs_aligner
import "https://raw.githubusercontent.com/antonkulaga/epigenetics/main/chip-seq/macs2.wdl" as macs

workflow chip_seq {
    input {
        Array[String] treatments
        Array[String] controls
        String format = "AUTO"
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
        Boolean deep_folder_structure = false
        String sequence_aligner = "minimap2"
        Boolean markdup = false
        Int compression = 9
        Boolean readgroup = false
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
            compression = compression,
            deep_folder_structure =  deep_folder_structure,
            readgroup = readgroup
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
            compression = compression,
            deep_folder_structure = deep_folder_structure,
            readgroup = readgroup
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

    call macs.macs2 as call_narrow {
        input: control = copy_control_aligned.out,
            treatment = copy_treatment_aligned.out,
            title = title,
            format = format,
            broad = false,
            destination = destination,
            out_dir = "narrow_peaks"
    }

    call macs.macs2 as call_broad {
        input:
            destination = destination,
            control = copy_control_aligned.out,
            treatment = copy_treatment_aligned.out,
            title = title,
            format = format,
            broad = true,
            out_dir = "broad_peaks"
    }

    output {
       File narrow = call_narrow.out
       File broad = call_broad.out
    }
}


task annotate_peaks {
    input {
        File reference
        File gtf
        File peak
        String name

    }

    command {
        annotatePeaks.pl ~{peak} ~{reference} -gtf ~{gtf} > ~{name}.bed
    }

    runtime {
        docker: "quay.io/biocontainers/homer:4.11--pl5262h7d875b9_4"
    }

    output {
        File out = name + ".bed"
    }
}
