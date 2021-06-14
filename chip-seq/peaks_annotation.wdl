version development
import "https://raw.githubusercontent.com/antonkulaga/bioworkflows/main/common/files.wdl" as files

workflow peaks_annotation
{
    input {
        File reference
        File gtf
        Array[File] peaks
        String destination
        String species = "Homo_sapiens"
    }

    scatter(peak in peaks){
       call annotate_peaks{
            input: reference = reference, gtf = gtf, peak = peak, name = basename(peak), species = species
       }
        call files.copy as copy_annotations {
            input: files = [annotate_peaks.out], destination = destination + "/"+ basename(peak)
        }
    }
}

task annotate_peaks {
    input {
        File reference
        File gtf
        File peak
        String name
        String species
    }

    String genome_name = species+"_ens"

    command {
        loadGenome.pl -name ~{genome_name} -org ~{species} -fasta ~{reference} -gtf ~{gtf}
        annotatePeaks.pl ~{peak} ~{genome_name} -genomeOntology ~{genome_name} > ~{name}.bed
    }

    runtime {
        docker: "quay.io/biocontainers/homer:4.11--pl5262h7d875b9_4"
    }

    output {
        File out = name + ".bed"
        #File go = name+"_go"
        #File genome_ontology = name + "_genome_ontology"
    }
}
