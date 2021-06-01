version development
workflow bsbolt_map_run {
    input {
        Array[File] reads
        File index
        String name
        Int bam_threads = 12
        Int bwa_threads = 12
        String read_group
        String destination
    }

    call align {
        input:
            reads = reads,
            index = index,
            name = name,
            bam_threads = bam_threads,
            read_group = read_group
    }
    call copy as alignment_copy{
        input: files = [align.out], destination = destination +"/" + name
    }

    output {
        Array[File] out = alignment_copy.out
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
        bsbolt Align -F1 ~{reads[0]} ~{if(length(reads)>1) then "-F2 " + reads[1] else " -p "} -DB ~{index} -O ~{name} -OT ~{bam_threads} -R '@RG ID:~{read_group}' -t ~{bwa_threads}
    }

    runtime {
        docker: "quay.io/comp-bio-aging/bsbolt:latest"
    }

    output {
        File out = name+".bam"
    }
}

task copy {
    input {
        Array[File] files
        String destination
    }

    String where = sub(destination, ";", "_")

    command {
        mkdir -p ~{where}
        cp -L -R -u ~{sep=' ' files} ~{where}
        declare -a files=(~{sep=' ' files})
        for i in ~{"$"+"{files[@]}"};
        do
        value=$(basename ~{"$"}i)
        echo ~{where}/~{"$"}value
        done
    }

    output {
        Array[File] out = read_lines(stdout())
    }
}