
rule all:
    input:
        "results/bcf/{sample}_final_variants.vcf.gz.tbi"

rule bwa_map:
    input:
        ref = "data/references.fa",
        sam = "data/samples/{sample}.fastq"
    output:
        "results/sam/{sample}.aligned.sam"
    shell:
        "bwa mem {input.ref} {input.sam} > {output}"

rule samtools_view:
    input:
        "results/sam/{sample}.aligned.sam"
    output:
        "results/bam/{sample}.aligned.bam"
    shell:
        "samtools view -S -b {input} > {output} "

rule samtools_sort:
    input:
        "results/bam/{sample}.aligned.bam"
    output:
        "results/bam/{sample}.aligned.sorted.bam"
    shell:
        "samtools sort -o {output} {input}"

rule bcftools_mpileup:
    input:
        ref = "data/references.fa",
        bam_sorted ="results/bam/{sample}.aligned.sorted.bam"
    output:
        "results/bcf/{sample}_raw.bcf"
    shell:
        "bcftools mpileup -d 1000 -Ob -o {output} "
        "-f {input.ref} {input.bam_sorted}"

rule bcftools_call:
    input:
        "results/bcf/{sample}_raw.bcf"
    output:
        "results/bcf/{sample}_variants.vcf"
    shell:
        "bcftools call --ploidy 1 -m -v -o {output} {input}"


rule vcfutils_filter:
    input:
        "results/bcf/{sample}_variants.vcf"
    output:
        "results/bcf/{sample}_final_variants.vcf"
    shell:
        "vcfutils.pl varFilter {input} > {output}"

rule compress:
    input:
        "results/bcf/{sample}_final_variants.vcf"
    output:
        "results/bcf/{sample}_final_variants.vcf.gz"
    shell:
        "bgzip -c {input} > {output} "

rule indices:
    input:
        "results/bcf/{sample}_final_variants.vcf.gz"
    output:
        "results/bcf/{sample}_final_variants.vcf.gz.tbi"
    shell:
        "tabix -p vcf {input}"

"""rule bcftools_consensus:
    input:
        fa = "data/references.fa",
        gz = "results/bcf/{sample}_final_variants.vcf.gz",
        gzt= "results/bcf/{sample}_final_variants.vcf.gz.tbi"
    output:
        "consensus/{sample}_consensus.fa"
    shell:
        "cat {input.fa} | bcftools consensus {input.gz} > {output}"
"""
