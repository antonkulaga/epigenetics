version development
workflow bsbolt_map_run {
    input {

    }
}


task align {
    input {
        Array[File] reads
        File index
        String name
        Int bam_threads = 12
        Int bwa_threads = 12
        String read_group
    }
    command {
        bsbolt Align -F1 ~{reads[0]} ~{if(length(reads)>1) then "-F2 " + reads[1] else ""} -DB ~{index} -O ~{name} -OT ~{bam_threads} -R '@RG ID:~{read_group}' -p \
      -t ~{bwa_threads}
    }

    runtime {
        docker: "quay.io/comp-bio-aging/bsbolt:latest"
    }

    output {
        File out = name
    }
}