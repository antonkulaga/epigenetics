version development
workflow bsbolt_index {
    input {
        File reference_fasta
        String index_name
        String destination
        File? mappable_regions
        Boolean ignore_alt_contigs = false
        Boolean reduced_representation #generate a Reduced Representative Bisulfite Sequencing (RRBS) index
        String rbbs_cut_format = "C-CGG" #Cut format to use for generation of RRBS database, [C-CGG] MSPI, input multiple enzymes as a comma separate string, C-CGG,C-CGG,...
        Int rrbs_lower = 40
        Int rrbs_upper = 500
    }

    call index{
        input:
        reference_fasta = reference_fasta,
        name = index_name,
        mappable_regions = mappable_regions,
        ignore_alt_contigs = ignore_alt_contigs,
        reduced_representation = reduced_representation,
        rbbs_cut_format =  rbbs_cut_format,
        rrbs_lower = rrbs_lower,
        rrbs_upper = rrbs_upper
    }

    call copy {
        input:
            files = [index.out],
            destination = destination
    }
}
task index {
    input {
        File reference_fasta
        String name
        File? mappable_regions
        Boolean ignore_alt_contigs = false
        Boolean reduced_representation #generate a Reduced Representative Bisulfite Sequencing (RRBS) index
        String rbbs_cut_format = "C-CGG" #Cut format to use for generation of RRBS database, [C-CGG] MSPI, input multiple enzymes as a comma separate string, C-CGG,C-CGG,...
        Int rrbs_lower = 40
        Int rrbs_upper = 500
    }
    command {
        bsbolt Index -G ~{reference_fasta} -DB ~{name} \
        ~{if(reduced_representation) then "-rrbs " + "-rrbs-lower "+ rrbs_lower + " -rrbs-upper" + rrbs_upper + " -rrbs-cut-format "+rbbs_cut_format else ""} \
        ~{"-MR " + mappable_regions} ~{if(ignore_alt_contigs) then "-IA" else ""}
    }
    output {
        File out = name
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