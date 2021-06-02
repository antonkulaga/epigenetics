version 1.0

workflow cross_map {

}
task cross_map_bed {
    input {

    }

    command {
        CrossMap.py bed
    }

    runtime {
        docker: "quay.io/biocontainers/crossmap:0.5.2--pyh7b7c402_0"
    }
}