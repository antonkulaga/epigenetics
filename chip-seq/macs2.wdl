version development
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/common/files.wdl" as files

workflow macs2 {
    input {
        Array[File] treatment
        Array[File] control
        String destination
        String title
        Boolean broad = false
        String format = "AUTO"
        String out_dir = "results"
    }

    call callpeak {
        input: control = control,
            treatment =treatment,
            name = title,
            format = format,
            broad = broad,
            out_dir = out_dir
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
        String out_dir
        String name
        String format = "AUTO"
        Boolean broad = true
    }

    String fixed_name = sub(name, " ", "_")

    command {
        macs2 callpeak \
        --outdir ~{out_dir} \
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
        File out   = out_dir
    }

}

