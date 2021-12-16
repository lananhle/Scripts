# Bioinformatics one-liners

[![DOI](https://zenodo.org/badge/3882/stephenturner/oneliners.svg)](https://zenodo.org/badge/latestdoi/3882/stephenturner/oneliners)

Useful bash one-liners useful for bioinformatics (and [some, more generally useful](#etc)).  


## Contents

- [Sources](#sources)
- [Basic awk & sed](#basic-awk--sed)
- [awk & sed for bioinformatics](#awk--sed-for-bioinformatics)
- [sort, uniq, cut, etc.](#sort-uniq-cut-etc)
- [find, xargs, and GNU parallel](#find-xargs-and-gnu-parallel)
- [seqtk](#seqtk)
- [GFF3 Annotations](#gff3-annotations)
- [Other generally useful aliases for your .bashrc](#other-generally-useful-aliases-for-your-bashrc)
- [Etc.](#etc)



## Sources

* <http://gettinggeneticsdone.blogspot.com/2013/10/useful-linux-oneliners-for-bioinformatics.html#comments>
* <http://sed.sourceforge.net/sed1line.txt>
* <https://github.com/lh3/seqtk>
* <http://lh3lh3.users.sourceforge.net/biounix.shtml>
* <http://genomespot.blogspot.com/2013/08/a-selection-of-useful-bash-one-liners.html>
* <http://biowize.wordpress.com/2012/06/15/command-line-magic-for-your-gene-annotations/>
* <http://genomics-array.blogspot.com/2010/11/some-unixperl-oneliners-for.html>
* <http://bioexpressblog.wordpress.com/2013/04/05/split-multi-fasta-sequence-file/>
* <http://www.commandlinefu.com/>



## Basic awk & sed

[[back to top](#contents)]


Extract fields 2, 4, and 5 from file.txt:

    awk '{print $2,$4,$5}' input.txt


Print each line where the 5th field is equal to ‘abc123’:

    awk '$5 == "abc123"' file.txt


Print each line where the 5th field is *not* equal to ‘abc123’:

    awk '$5 != "abc123"' file.txt


Print each line whose 7th field matches the regular expression:

    awk '$7  ~ /^[a-f]/' file.txt


Print each line whose 7th field *does not* match the regular expression:

    awk '$7 !~ /^[a-f]/' file.txt


Get unique entries in file.txt based on column 2 (takes only the first instance):

    awk '!arr[$2]++' file.txt


Print rows where column 3 is larger than column 5 in file.txt:

    awk '$3>$5' file.txt


Sum column 1 of file.txt:

    awk '{sum+=$1} END {print sum}' file.txt


Compute the mean of column 2:

    awk '{x+=$2}END{print x/NR}' file.txt


Replace all occurances of `foo` with `bar` in file.txt:

    sed 's/foo/bar/g' file.txt


Trim leading whitespaces and tabulations in file.txt:

    sed 's/^[ \t]*//' file.txt


Trim trailing whitespaces and tabulations in file.txt:

    sed 's/[ \t]*$//' file.txt


Trim leading and trailing whitespaces and tabulations in file.txt:

    sed 's/^[ \t]*//;s/[ \t]*$//' file.txt


Delete blank lines in file.txt:

    sed '/^$/d' file.txt


Delete everything after and including a line containing `EndOfUsefulData`:

    sed -n '/EndOfUsefulData/,$!p' file.txt

Remove duplicates while preserving order

    awk '!visited[$0]++' file.txt



## awk & sed for bioinformatics

[[back to top](#contents)]


Returns all lines on Chr 1 between 1MB and 2MB in file.txt. (assumes) chromosome in column 1 and position in column 3 (this same concept can be used to return only variants that above specific allele frequencies):

    cat file.txt | awk '$1=="1"' | awk '$3>=1000000' | awk '$3<=2000000'


Basic sequence statistics. Print total number of reads, total number unique reads, percentage of unique reads, most abundant sequence, its frequency, and percentage of total in file.fq:

    cat myfile.fq | awk '((NR-2)%4==0){read=$1;total++;count[read]++}END{for(read in count){if(!max||count[read]>max) {max=count[read];maxRead=read};if(count[read]==1){unique++}};print total,unique,unique*100/total,maxRead,count[maxRead],count[maxRead]*100/total}'


Convert .bam back to .fastq:

    samtools view file.bam | awk 'BEGIN {FS="\t"} {print "@" $1 "\n" $10 "\n+\n" $11}' > file.fq


Keep only top bit scores in blast hits (best bit score only):

    awk '{ if(!x[$1]++) {print $0; bitscore=($14-1)} else { if($14>bitscore) print $0} }' blastout.txt


Keep only top bit scores in blast hits (5 less than the top):

    awk '{ if(!x[$1]++) {print $0; bitscore=($14-6)} else { if($14>bitscore) print $0} }' blastout.txt


Split a multi-FASTA file into individual FASTA files:

    awk '/^>/{s=++d".fa"} {print > s}' multi.fa

Output sequence name and its length for every sequence within a fasta file:

    cat file.fa | awk '$0 ~ ">" {print c; c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }'

Convert a FASTQ file to FASTA:

    sed -n '1~4s/^@/>/p;2~4p' file.fq > file.fa

Extract every 4th line starting at the second line (extract the sequence from FASTQ file):

    sed -n '2~4p' file.fq

Print everything except the first line

    awk 'NR>1' input.txt

Print rows 20-80:

    awk 'NR>=20&&NR<=80' input.txt

Calculate the sum of column 2 and 3 and put it at the end of a row:

    awk '{print $0,$2+$3}' input.txt

Calculate the mean length of reads in a fastq file:

    awk 'NR%4==2{sum+=length($0)}END{print sum/(NR/4)}' input.fastq

Convert a VCF file to a BED file

    sed -e 's/chr//' file.vcf | awk '{OFS="\t"; if (!/^#/){print $1,$2-1,$2,$4"/"$5,"+"}}'

Create a tab-delimited transcript-to-gene mapping table from a GENCODE GFF. The `substr(x,s,n)` returns _n_ characters from string _x_ starting from position _s_. This gets rid of the quotes and semicolon.

    bioawk -c gff '$feature=="transcript" {print $group}' gencode.v28.annotation.gtf | awk -F ' ' '{print substr($4,2,length($4)-3) "\t" substr($2,2,length($2)-3)}' > txp2gene.tsv

extract specific reads from fastq file according to reads name :

    zcat a.fastq.gz | awk 'BEGIN{RS="@";FS="\n"}; $1~/readsName/{print $2; exit}'

count missing sample in vcf file per line:

    bcftools query -f '[%GT\t]\n' a.bcf |  awk '{miss=0};{for (x=1; x<=NF; x++) if ($x=="./.") {miss+=1}};{print miss}' > nmiss.count


## sort, uniq, cut, etc.

[[back to top](#contents)]

Number each line in file.txt:

    cat -n file.txt

Count the number of unique lines in file.txt

    cat file.txt | sort -u | wc -l


Find lines shared by 2 files (assumes lines within file1 and file2 are unique; pipe to `wd -l` to count the _number_ of lines shared):

    sort file1 file2 | uniq -d

    # Safer
    sort -u file1 > a
    sort -u file2 > b
    sort a b | uniq -d

    # Use comm
    comm -12 file1 file2


Sort numerically (with logs) (g) by column (k) 9:

    sort -gk9 file.txt


Find the most common strings in column 2:

    cut -f2 file.txt | sort | uniq -c | sort -k1nr | head


Pick 10 random lines from a file:

    shuf file.txt | head -n 10


Print all possible 3mer DNA sequence combinations:

    echo {A,C,T,G}{A,C,T,G}{A,C,T,G}


Untangle an interleaved paired-end FASTQ file. If a FASTQ file has paired-end reads intermingled, and you want to separate them into separate /1 and /2 files, and assuming the /1 reads precede the /2 reads:

    cat interleaved.fq |paste - - - - - - - - | tee >(cut -f 1-4 | tr "\t" "\n" > deinterleaved_1.fq) | cut -f 5-8 | tr "\t" "\n" > deinterleaved_2.fq

Take a fasta file with a bunch of short scaffolds, e.g., labeled `>Scaffold12345`, remove them, and write a new fasta without them:

    samtools faidx genome.fa && grep -v Scaffold genome.fa.fai | cut -f1 | xargs -n1 samtools faidx genome.fa > genome.noscaffolds.fa

Display hidden control characters:

    python -c "f = open('file.txt', 'r'); f.seek(0); file = f.readlines(); print file" 


## find, xargs, and GNU parallel

[[back to top](#contents)]


*Download GNU parallel at <https://www.gnu.org/software/parallel/>.*


Search for .bam files anywhere in the current directory recursively:

    find . -name "*.bam"


Delete all .bam files (Irreversible: use with caution! Confirm list BEFORE deleting):

    find . -name "*.bam" | xargs rm


Rename all .txt files to .bak (backup *.txt before doing something else to them, for example):

    find . -name "*.txt" | sed "s/\.txt$//" | xargs -i echo mv {}.txt {}.bak | sh


Chastity filter raw Illumina data (grep reads containing `:N:`, append (-A) the three lines after the match containing the sequence and quality info, and write a new filtered fastq file):

    find *fq | parallel "cat {} | grep -A 3 '^@.*[^:]*:N:[^:]*:' | grep -v '^\-\-$' > {}.filt.fq"


Run FASTQC in parallel 12 jobs at a time:

    find *.fq | parallel -j 12 "fastqc {} --outdir ."


Index your bam files in parallel, but only echo the commands (`--dry-run`) rather than actually running them:

    find *.bam | parallel --dry-run 'samtools index {}'


## seqtk

[[back to top](#contents)]

*Download seqtk at <https://github.com/lh3/seqtk>. Seqtk is a fast and lightweight tool for processing sequences in the FASTA or FASTQ format. It seamlessly parses both FASTA and FASTQ files which can also be optionally compressed by gzip.*


Convert FASTQ to FASTA:

    seqtk seq -a in.fq.gz > out.fa


Convert ILLUMINA 1.3+ FASTQ to FASTA and mask bases with quality lower than 20 to lowercases (the 1st command line) or to `N` (the 2nd):

    seqtk seq -aQ64 -q20 in.fq > out.fa
    seqtk seq -aQ64 -q20 -n N in.fq > out.fa


Fold long FASTA/Q lines and remove FASTA/Q comments:

    seqtk seq -Cl60 in.fa > out.fa


Convert multi-line FASTQ to 4-line FASTQ:

    seqtk seq -l0 in.fq > out.fq


Reverse complement FASTA/Q:

    seqtk seq -r in.fq > out.fq


Extract sequences with names in file `name.lst`, one sequence name per line:

    seqtk subseq in.fq name.lst > out.fq


Extract sequences in regions contained in file `reg.bed`:

    seqtk subseq in.fa reg.bed > out.fa


Mask regions in `reg.bed` to lowercases:

    seqtk seq -M reg.bed in.fa > out.fa


Subsample 10000 read pairs from two large paired FASTQ files (remember to use the same random seed to keep pairing):

    seqtk sample -s100 read1.fq 10000 > sub1.fq
    seqtk sample -s100 read2.fq 10000 > sub2.fq


Trim low-quality bases from both ends using the Phred algorithm:

    seqtk trimfq in.fq > out.fq


Trim 5bp from the left end of each read and 10bp from the right end:

    seqtk trimfq -b 5 -e 10 in.fa > out.fa


Untangle an interleaved paired-end FASTQ file. If a FASTQ file has paired-end reads intermingled, and you want to separate them into separate /1 and /2 files, and assuming the /1 reads precede the /2 reads:

    seqtk seq -l0 -1 interleaved.fq > deinterleaved_1.fq
    seqtk seq -l0 -2 interleaved.fq > deinterleaved_2.fq




## GFF3 Annotations

[[back to top](#contents)]


Print all sequences annotated in a GFF3 file.

    cut -s -f 1,9 yourannots.gff3 | grep $'\t' | cut -f 1 | sort | uniq


Determine all feature types annotated in a GFF3 file.

    grep -v '^#' yourannots.gff3 | cut -s -f 3 | sort | uniq


Determine the number of genes annotated in a GFF3 file.

    grep -c $'\tgene\t' yourannots.gff3


Extract all gene IDs from a GFF3 file.

    grep $'\tgene\t' yourannots.gff3 | perl -ne '/ID=([^;]+)/ and printf("%s\n", $1)'


Print length of each gene in a GFF3 file.

    grep $'\tgene\t' yourannots.gff3 | cut -s -f 4,5 | perl -ne '@v = split(/\t/); printf("%d\n", $v[1] - $v[0] + 1)'


FASTA header lines to GFF format (assuming the length is in the header as an appended "\_length" as in [Velvet](http://www.ebi.ac.uk/~zerbino/velvet/) assembled transcripts):

    grep '>' file.fasta | awk -F "_" 'BEGIN{i=1; print "##gff-version 3"}{ print $0"\t BLAT\tEXON\t1\t"$10"\t95\t+\t.\tgene_id="$0";transcript_id=Transcript_"i;i++ }' > file.gff




## Other generally useful aliases for your .bashrc

[[back to top](#contents)]


Get a prompt that looks like `user@hostname:/full/path/cwd/:$ `

    export PS1="\u@\h:\w\\$ "


Never type `cd ../../..` again (or use [autojump](https://github.com/joelthelion/autojump), which enables you to navigate the filesystem faster):

    alias ..='cd ..'
    alias ...='cd ../../'
    alias ....='cd ../../../'
    alias .....='cd ../../../../'
    alias ......='cd ../../../../../'

Browse 'up' and 'down'

    alias u='clear; cd ../; pwd; ls -lhGgo'
    alias d='clear; cd -; ls -lhGgo'


Ask before removing or overwriting files:

    alias mv="mv -i"
    alias cp="cp -i"  
    alias rm="rm -i"


My favorite `ls` aliases:

    alias ls="ls -1p --color=auto"
    alias l="ls -lhGgo"
    alias ll="ls -lh"
    alias la="ls -lhGgoA"
    alias lt="ls -lhGgotr"
    alias lS="ls -lhGgoSr"
    alias l.="ls -lhGgod .*"
    alias lhead="ls -lhGgo | head"
    alias ltail="ls -lhGgo | tail"
    alias lmore='ls -lhGgo | more'


Use `cut` on space- or comma- delimited files:

    alias cuts="cut -d \" \""
    alias cutc="cut -d \",\""


Pack and unpack tar.gz files:

    alias tarup="tar -zcf"
    alias tardown="tar -zxf"


Or use a generalized `extract` function:

    # as suggested by Mendel Cooper in "Advanced Bash Scripting Guide"
    extract () {
       if [ -f $1 ] ; then
           case $1 in
            *.tar.bz2)      tar xvjf $1 ;;
            *.tar.gz)       tar xvzf $1 ;;
            *.tar.xz)       tar Jxvf $1 ;;
            *.bz2)          bunzip2 $1 ;;
            *.rar)          unrar x $1 ;;
            *.gz)           gunzip $1 ;;
            *.tar)          tar xvf $1 ;;
            *.tbz2)         tar xvjf $1 ;;
            *.tgz)          tar xvzf $1 ;;
            *.zip)          unzip $1 ;;
            *.Z)            uncompress $1 ;;
            *.7z)           7z x $1 ;;
            *)              echo "don't know how to extract '$1'..." ;;
           esac
       else
           echo "'$1' is not a valid file!"
       fi
    }



Use `mcd` to create a directory and `cd` to it simultaneously:

    function mcd { mkdir -p "$1" && cd "$1";}


Go up to the parent directory and list it's contents:

    alias u="cd ..;ls"


Make grep pretty:

    alias grep="grep --color=auto"


Refresh your `.bashrc`:

    alias refresh="source ~/.bashrc"

Edit your `.bashrc`:

    alias eb="vi ~/.bashrc"

Common typos:

    alias mf="mv -i"
    alias mroe="more"
    alias c='clear'
    alias emacs='vim'

Show your `$PATH` in a prettier format:

    alias showpath='echo $PATH | tr ":" "\n" | nl'

Use [pandoc](http://johnmacfarlane.net/pandoc/) to convert a markdown file to PDF:

    # USAGE: mdpdf document.md document.md.pdf
    alias mdpdf="pandoc -s -V geometry:margin=1in -V documentclass:article -V fontsize=12pt"


Find text in any file (`ft "mytext" *.txt`):

    function ft { find . -name "$2" -exec grep -il "$1" {} \;; }

## Etc
[[back to top](#contents)]

Run the last command as root:

    sudo !!

Place the argument of the most recent command on the shell:

    'ALT+.' or '<ESC> .'

Type partial command, kill this command, check something you forgot, yank the command, resume typing:

    <CTRL+u> [...] <CTRL+y>

Jump to a directory, execute a command, and jump back to the current directory:

    (cd /tmp && ls)

Stopwatch (`Enter` or `ctrl-d` to stop):

    time read

Create a script of the last executed command:

    echo "!!" > foo.sh

Reuse _all_ parameter of the previous command line:

    !*

List or delete all files in a folder that don't match a certain file extension (e.g., list things that are _not_ compressed; remove anything that is _not_ a `.foo` or `.bar` file):

    ls !(*.gz)
    rm !(*.foo|*.bar)

Insert the last command without the last argument:

    !:- <new_last_argument>

Rapidly invoke an editor to write a long, complex, or tricky command:

    fc

Print a specific line (e.g. line 42) from a file:

    sed -n 42p <file>

Terminate a frozen SSH session (enter a new line, type the `~` key then the `.` key):

    [ENTER]~.

Remove blank lines from a file using grep and save output to new file:

    grep . filename > newfilename

Find large files (e.g., >500M):

    find . -type f -size +500M

Exclude a column with cut (e.g., all but the 5th field in a tab-delimited file):

    cut -f5 --complement

Find files containing text (`-l` outputs only the file names, `-i` ignores the case `-r` descends into subdirectories)

    grep -lir "some text" *

# bioinformatics-one-liners
my collection of bioinformatics one liners that is useful in my day-to-day work

### I came across the bioinformatics one-liners on the [biostar](https://www.biostars.org/p/142545/) forum and gathered them here.
I also added some of my own tricks

05/21/2015.



####  get the sequences length distribution form a fastq file using awk

```bash
zcat file.fastq.gz | awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}'  
```

#### add barcode to 10x single cell R1 read

```bash
cat test.fq | awk 'NR%4 == 2 {$0="xxx"$0}{print}'
@D00365:1187:HMM2FBCX2:1:1103:1258:2132 1:N:0:CGTGCAGA
xxxTATTACCAGATGAGAGCATGGTTAGG
+
DDDDDIIIIIIIHIIIIIIIIIIIII
@D00365:1187:HMM2FBCX2:1:1103:1472:2136 1:N:0:CGTGCAGA
xxxAACCATGAGTGTCCCGCTGGCATCGC
+
DDDADGHHIIHIIGIHHHFCHHIIII
@D00365:1187:HMM2FBCX2:1:1103:1822:2139 1:N:0:CGTGCAGA
xxxGTGCATATCATGTAGCGTATTATACT
+
DDDDDIIIIIIIIIIIIIIIIIIIII
@D00365:1187:HMM2FBCX2:1:1103:1943:2145 1:N:0:CGTGCAGA
xxxGATTCAGTCTCCAACCTCTCCTTTGT
+
DDDDDHIIIIIIIIIIHIIIIHIIII
@D00365:1187:HMM2FBCX2:1:1103:1917:2147 1:N:0:CGTGCAGA
xxxCCTTCGACAAGTTGTCAGGTGCGGTC
+
DDDDDHIIIIIIIIIIIIIIGIIHHH
```
#### Reverse complement a sequence (I use that a lot when I need to design primers)

```
echo 'ATTGCTATGCTNNNT' | rev | tr 'ACTG' 'TGAC'
```

#### split a multifasta file into single ones with csplit:

```bash
csplit -z -q -n 4 -f sequence_ sequences.fasta /\>/ {*}  
```
#### Split a multi-FASTA file into individual FASTA files by awk

```bash
awk '/^>/{s=++d".fa"} {print > s}' multi.fa
```

#### linearize multiline fasta

```bash
cat file.fasta | awk '/^>/{if(N>0) printf("\n"); ++N; printf("%s\t",$0);next;} {printf("%s",$0);}END{printf("\n");}'
awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' file.fa
```
#### fastq2fasta

```bash
zcat file.fastq.gz | paste - - - - | perl -ane 'print ">$F[0]\n$F[2]\n";' | gzip -c > file.fasta.gz
```
####  bam2bed

```bash
samtools view file.bam | perl -F'\t' -ane '$strand=($F[1]&16)?"-":"+";$length=1;$tmp=$F[5];$tmp =~ s/(\d+)[MD]/$length+=$1/eg;print "$F[2]\t$F[3]\t".($F[3]+$length)."\t$F[0]\t0\t$strand\n";' > file.bed
```

#### bam2wig

```bash
samtools mpileup -BQ0 file.sorted.bam | perl -pe '($c, $start, undef, $depth) = split;if ($c ne $lastC || $start != $lastStart+1) {print "fixedStep chrom=$c start=$start step=1 span=1\n";}$_ = $depth."\n";($lastC, $lastStart) = ($c, $start);' | gzip -c > file.wig.gz
```

#### Number of reads in a fastq file

```bash
cat file.fq | echo $((`wc -l`/4))
```
#### Single line fasta file to multi-line fasta of 60 characteres each line

```bash
awk -v FS= '/^>/{print;next}{for (i=0;i<=NF/60;i++) {for (j=1;j<=60;j++) printf "%s", $(i*60 +j); print ""}}' file

fold -w 60 file
```

#### Sequence length of every entry in a multifasta file

```bash
awk '/^>/ {if (seqlen){print seqlen}; print ;seqlen=0;next; } { seqlen = seqlen +length($0)}END{print seqlen}' file.fa
```
#### Reproducible subsampling of a FASTQ file. srand() is the seed for the random number generator - keeps the subsampling the same when the script is run multiple times.  0.01 is the % of reads to output.

```bash
cat file.fq | paste - - - - | awk 'BEGIN{srand(1234)}{if(rand() < 0.01) print $0}' | tr '\t' '\n' > out.fq
```
#### or look at the Hengli's Seqtk 

#### Deinterleaving a FASTQ:

```bash
cat file.fq | paste - - - - - - - - | tee >(cut -f1-4 | tr '\t'  
'\n' > out1.fq) | cut -f5-8 | tr '\t' '\n' > out2.fq
```

#### Using mpileup for a whole genome can take forever. So, handling each chromosome separately and parallely running them on several cores will speed up your pipeline. Using xargs you can easily realize it.  
#### Example usage of xargs (-P is the number of parallel processes started - don't use more than the number of cores you have available):

```basg
samtools view -H yourFile.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f 1 | xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d 100000 -uf yourGenome.fa -r {} yourFile.bam | bcftools view -vcg - > tmp.{}.vcf"
```

#### To merge the results afterwards, you might want to do something like this:

```bash
samtools view -H yourFile.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f 1 | perl -ane 'system("cat tmp.$F[0].bcf >> yourFile.vcf");'
```

#### split large file by id/label/column

```bash
awk '{print >> $1; close($1)}' input_file
```
#### split a bed file by chromosome:

```bash
cat nexterarapidcapture_exome_targetedregions_v1.2.bed | sort -k1,1 -k2,2n | sed 's/^chr//' | awk '{close(f);f=$1}{print > f".bed"}'

#or
awk '{print $0 >> $1".bed"}' example.bed
```

#### sort vcf file with header

```bash
cat my.vcf | awk '$0~"^#" { print $0; next } { print $0 | "sort -k1,1V -k2,2n" }'
```
#### Rename a file, bash string manipulation

```bash
for file in *gz
do zcat $file > ${file/bed.gz/bed}
```

#### gnu sed print invisible characters

```bash
cat my_file | sed -n 'l'
cat -A
```

#### exit a dead ssh session
`~.`

#### copy large files, copy the from_dir directory inside the to_dir directory

```bash
rsync -av from_dir  to_dir

## copy every file inside the frm_dir to to_dir
rsync -av from_dir/ to_dir

##re-copy the files avoiding completed ones:

rsync -avhP /from/dir /to/dir
```

#### make directory using the current date

```bash
mkdir $(date +%F)
```
#### all the folders' size in the current folder (GNU du)

```bash
du -h --max-depth=1
```

### this one is a bit different, try it and see the difference
`du -ch`

#### the total size of current directory
`du -sh .`

#### disk usage
`df -h`

#### the column names of the file, install csvkit https://csvkit.readthedocs.org/en/0.9.1/
`csvcut -n`

#### open top with human readable size in Mb, Gb. install htop for better visualization
`top -M`

#### how many memeory are used in Gb
`free -mg`

#### print out unique rows based on the first and second column
`awk '!a[$1,$2]++' input_file`

`sort -u -k1,2 file`
It will sort based on unique first and second column

#### do not wrap the lines using less
`less -S`

#### pretty output
```bash
fold -w 60
cat file.txt | column -t | less -S
```
#### pass tab as delimiter http://unix.stackexchange.com/questions/46910/is-it-a-bug-for-join-with-t-t
`-t $'\t'`

#### awk with the first line printed always
`awk ' NR ==1 || ($10 > 1 && $11 > 0 && $18 > 0.001)'  input_file`

#### delete blank lines with sed
`sed /^$/d`

#### delete the last line
`sed $d`

awk to join files based on several columns

my [github repo](https://github.com/crazyhottommy/scripts-general-use/blob/master/Shell/Awk_anotates_vcf_with_bed.ipynb)

```
### select lines from a file based on columns in another file
## http://unix.stackexchange.com/questions/134829/compare-two-columns-of-different-files-and-print-if-it-matches
awk -F"\t" 'NR==FNR{a[$1$2$3]++;next};a[$1$2$3] > 0' file2 file1 

```

Finally learned about the !$ in unix: take the last thing (word) from the previous command.   
`echo hello, world; echo !$` gives 'world'


Create a script of the last executed command:  
`echo "!!" > foo.sh`

Reuse all parameter of the previous command line:  
`!*`

find bam in current folder (search recursively) and copy it to a new directory using 5 CPUs    
`find . -name "*bam" | xargs -P5 -I{} rsync -av {} dest_dir`

`ls -X`  will group files by extension.

loop through all the chromosomes

```bash
for i in {1..22} X Y 
do
  echo $i
done
```

for i in in `{01..22}` will expand to 01 02 ...


change every other newline to tab:

`paste` is used to concatenate corresponding lines from files: paste file1 file2 file3 .... If one of the "file" arguments is "-", then lines are read from standard input. If there are 2 "-" arguments, then paste takes 2 lines from stdin. And so on.

```bash
cat test.txt  
0    ATTTTATTNGAAATAGTAGTGGG
0    CTCCCAAAATACTAAAATTATAA
1    TTTTAGTTATTTANGAGGTTGAG
1    CNTAATCTTAACTCACTACAACC
2    TTATAATTTTAGTATTTTGGGAG
2    CATATTAACCAAACTAATCTTAA
3    GGTTAATATGGTGAAATTTAAT
3    ACCTCAACCTCNTAAATAACTAA

cat test.txt| paste - -                               
0    ATTTTATTNGAAATAGTAGTGGG    0    CTCCCAAAATACTAAAATTATAA
1    TTTTAGTTATTTANGAGGTTGAG    1    CNTAATCTTAACTCACTACAACC
2    TTATAATTTTAGTATTTTGGGAG    2    CATATTAACCAAACTAATCTTAA
3    GGTTAATATGGTGAAATTTAAT     3    ACCTCAACCTCNTAAATAACTAA
```

ORS: output record seperator in `awk`
`var=condition?condition_if_true:condition_if_false is the ternary operator.`

```bash
cat test.txt| awk 'ORS=NR%2?"\t":"\n"'          

0    ATTTTATTNGAAATAGTAGTGGG    0    CTCCCAAAATACTAAAATTATAA
1    TTTTAGTTATTTANGAGGTTGAG    1    CNTAATCTTAACTCACTACAACC
2    TTATAATTTTAGTATTTTGGGAG    2    CATATTAACCAAACTAATCTTAA
3    GGTTAATATGGTGAAATTTAAT     3    ACCTCAACCTCNTAAATAACTAA

```

#### awk
We can also use the concept of a conditional operator in print statement of the form print CONDITION ? PRINT_IF_TRUE_TEXT : PRINT_IF_FALSE_TEXT. For example, in the code below, we identify sequences with lengths > 14:

```bash
cat data/test.tsv
blah_C1	ACTGTCTGTCACTGTGTTGTGATGTTGTGTGTG
blah_C2	ACTTTATATATT
blah_C3	ACTTATATATATATA
blah_C4	ACTTATATATATATA
blah_C5	ACTTTATATATT	

awk '{print (length($2)>14) ? $0">14" : $0"<=14";}' data/test.tsv
blah_C1	ACTGTCTGTCACTGTGTTGTGATGTTGTGTGTG>14
blah_C2	ACTTTATATATT<=14
blah_C3	ACTTATATATATATA>14
blah_C4	ACTTATATATATATA>14
blah_C5	ACTTTATATATT<=14

awk 'NR==3{print "";next}{printf $1"\t"}{print $1}' data/test.tsv
blah_C1	blah_C1
blah_C2	blah_C2

blah_C4	blah_C4
blah_C5	blah_C5

```
You can also use getline to load the contents of another file in addition to the one you are reading, for example, in the statement given below, the while loop will load each line from test.tsv into k until no more lines are to be read:
```bash
awk 'BEGIN{while((getline k <"data/test.tsv")>0) print "BEGIN:"k}{print}' data/test.tsv
BEGIN:blah_C1	ACTGTCTGTCACTGTGTTGTGATGTTGTGTGTG
BEGIN:blah_C2	ACTTTATATATT
BEGIN:blah_C3	ACTTATATATATATA
BEGIN:blah_C4	ACTTATATATATATA
BEGIN:blah_C5	ACTTTATATATT
blah_C1	ACTGTCTGTCACTGTGTTGTGATGTTGTGTGTG
blah_C2	ACTTTATATATT
blah_C3	ACTTATATATATATA
blah_C4	ACTTATATATATATA
blah_C5	ACTTTATATATT
```
#### merge multiple fasta sequences in two files into a single file line by line
see [post](https://www.biostars.org/p/204336/#204380)  

`linearize.awk:`  

```bash
/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}
```

```bash
paste <(awk -f linearize.awk file1.fa ) <(awk -f linearize.awk file2.fa  )| tr "\t" "\n"
```

#### grep fastq reads containing a pattern but maintain the fastq format

```bash
grep -A 2 -B 1 'AAGTTGATAACGGACTAGCCTTATTTT' file.fq | sed '/^--$/d' > out.fq

# or
zcat reads.fq.gz \
| paste - - - - \
| awk -v FS="\t" -v OFS="\n" '$2 ~ "AAGTTGATAACGGACTAGCCTTATTTT" {print $1, $2, $3, $4}' \
| gzip > filtered.fq.gz
```

#### count how many columns of a tsv files: 
```bash
cat file.tsv | head -1 | tr "\t" "\n" | wc -l  
csvcut -n -t  file.tsv (from csvkit)
awk '{print NF; exit}' file.tsv
awk -F "\t" 'NR == 1 {print NF}' file.tsv
```

#### combine info to the fasta header

[from biostar post](https://www.biostars.org/p/212379/#212393)
```bash
cat myfasta.txt 
>Blap_contig79
MSTDVDAKTRSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>Bluc_contig23663
MSTNVDAKARSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>Blap_contig7988
MSTDVDAKTRSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>Bluc_contig1223663
MSTNVDAKARSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI

cat my_info.txt 
info1
info2
info3
info4

paste <(cat my_info.txt) <(cat myfasta.txt| paste - - | cut -c2-) | awk '{printf(">%s_%s\n%s\n",$1,$2,$3);}'
>info1_Blap_contig79
MSTDVDAKTRSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>info2_Bluc_contig23663
MSTNVDAKARSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>info3_Blap_contig7988
MSTDVDAKTRSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI
>info4_Bluc_contig1223663
MSTNVDAKARSKERASIAAFYVGRNIFVTGGTGFLGKVLIEKLLRSCPDVGEIFILMRPKAGLSI

```

#### count how many columns in a tsv file

```bash
cat file.tsv | head -1 | tr "\t" "\n" | wc -l  

##(from csvkit)
csvcut -n -t file.

## emulate csvcut -n -t
less files.tsv | head -1| tr "\t" "\n" | nl

awk -F "\t" 'NR == 1 {print NF}' file.tsv
awk '{print NF; exit}'
```
#### change fasta header

see https://www.biostars.org/p/53212/

The fasta header is like `>7 dna:chromosome chromosome:GRCh37:7:1:159138663:1`
convert to `>7`: 

```bash
cat Homo_sapiens_assembly19.fasta | gawk '/^>/ { b=gensub(" dna:.+", "", "g", $0); print b; next} {print}' > Homo_sapiens_assembly19_reheader.fasta
```
### mkdir and cd into that dir shortcut

```bash
mkdir blah && cd $_
```
### cut out columns based on column names in another file

http://crazyhottommy.blogspot.com/2016/10/cutting-out-500-columns-from-26g-file.html

```bash
#! /bin/bash

set -e
set -u
set -o pipefail

#### Author: Ming Tang (Tommy)
#### Date 09/29/2016
#### I got the idea from this stackOverflow post http://stackoverflow.com/questions/11098189/awk-extract-columns-from-file-based-on-header-selected-from-2nd-file

# show help
show_help(){
cat << EOF
  This is a wrapper extracting columns of a (big) dataframe based on a list of column names in another
  file. The column names must be one per line. The output will be stdout. For small files < 2G, one 
  can load it into R and do it easily, but when the file is big > 10G. R is quite cubersome. 
  Using unix commands on the other hand is better because files do not have to be loaded into memory at once.
  e.g. subset a 26G size file for 700 columns takes around 30 mins. Memory footage is very low ~4MB.

  usage: ${0##*/} -f < a dataframe  > -c < colNames> -d <delimiter of the file>
        -h display this help and exit.
		-f the file you want to extract columns from. must contain a header with column names.
		-c a file with the one column name per line.
		-d delimiter of the dataframe: , or \t. default is tab.  
		
		e.g. 
		
		for tsv file:
			${0##*/} -f mydata.tsv -c colnames.txt -d $'\t' or simply ommit the -d, default is tab.
		
		for csv file: Note you have to specify -d , if your file is csv, otherwise all columns will be cut out.
			${0##*/} -f mydata.csv -c colnames.txt -d ,
        
EOF
}

## if there are no arguments provided, show help
if [[ $# == 0 ]]; then show_help; exit 1; fi

while getopts ":hf:c:d:" opt; do
  case "$opt" in
    h) show_help;exit 0;;
    f) File2extract=$OPTARG;;
    c) colNames=$OPTARG;;
    d) delim=$OPTARG;;
    '?') echo "Invalid option $OPTARG"; show_help >&2; exit 1;;
  esac
done
	

## set up the default delimiter to be tab, Note the way I specify tab 

delim=${delim:-$'\t'}

## get the number of columns in the data frame that match the column names in the colNames file.
## change the output to 2,5,6,22,... and get rid of the last comma  so cut -f can be used
 
cols=$(head -1 "${File2extract}" | tr "${delim}" "\n" | grep -nf "${colNames}" | sed 's/:.*$//' | tr "\n" "," | sed 's/,$//')

## cut out the columns 
cut -d"${delim}" -f"${cols}" "${File2extract}"
```
or use [csvtk](https://github.com/shenwei356/csvtk) from Shen Wei:  

```bash
csvtk cut -t -f $(paste -s -d , list.txt) data.tsv
```
#### merge all bed files and add a column for the filename.

```bash
awk '{print $0 "\t" FILENAME}' *bed 
```

### add or remove chr from the start of each line

```bash
# add chr
sed 's/^/chr/' my.bed

# or
awk 'BEGIN {OFS = "\t"} {$1="chr"$1; print}'

# remove chr
sed 's/^chr//' my.bed
```
### check if a tsv files have the same number of columns for all rows

```bash
awk '{print NF}' test.tsv | sort -nu | head -n 1
```

### Parallelized samtools mpileup 

https://www.biostars.org/p/134331/

```bash
BAM="yourFile.bam"
REF="reference.fasta"
samtools view -H $BAM | grep "\@SQ" | sed 's/^.*SN://g' | cut -f 1 | xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d 100000 -uf $REF -r \"{}\" $BAM | bcftools call -cv > \"{}\".vcf"
```
### convert multiple lines to a single line

This is better than `tr "\n" "\t"` because somtimes I do not want to convert the last newline to tab.

```bash
cat myfile.txt | paste -s 
```

### merge multiple files with same header by keeping the header of the first file
I usually do it in R, but like the quick solution.

https://stackoverflow.com/questions/16890582/unixmerge-multiple-csv-files-with-same-header-by-keeping-the-header-of-the-firs

```bash
awk 'FNR==1 && NR!=1{next;}{print}' *.csv 

# or

awk '
    FNR==1 && NR!=1 { while (/^<header>/) getline; }
    1 {print}
' file*.txt >all.txt
```

### insert a field into the first line

```bash
cut -f1-4 F5.hg38.enhancers.expression.usage.matrix | head
CNhs11844	CNhs11251	CNhs11282	CNhs10746
chr10:100006233-100006603	1	0	0
chr10:100008181-100008444	0	0	0
chr10:100014348-100014634	0	0	0
chr10:100020065-100020562	0	0	0
chr10:100043485-100043744	0	0	0
chr10:100114218-100114567	0	0	0
chr10:100148595-100148922	0	0	0
chr10:100182422-100182522	0	0	0
chr10:100184498-100184704	0	0	0

sed '1 s/^/enhancer\t/' F5.hg38.enhancers.expression.usage.matrix | cut -f1-4 | head
enhancer	CNhs11844	CNhs11251	CNhs11282
chr10:100006233-100006603	1	0	0
chr10:100008181-100008444	0	0	0
chr10:100014348-100014634	0	0	0
chr10:100020065-100020562	0	0	0
chr10:100043485-100043744	0	0	0
chr10:100114218-100114567	0	0	0
chr10:100148595-100148922	0	0	0
chr10:100182422-100182522	0	0	0
chr10:100184498-100184704	0	0	0

```
### extract PASS calls from vcf file

```
cat my.vcf | awk -F '\t' '{if($0 ~ /\#/) print; else if($7 == "PASS") print}' > my_PASS.vcf

```

### replace a pattern in a specific column

```
## column5 
awk '{gsub(pattern,replace,$5)}1' in.file

## http://bioinf.shenwei.me/csvtk/usage/#replace
csvtk replace -f 5 -p pattern -r replacement 

```
### move a process to a screen session

https://www.linkedin.com/pulse/move-running-process-screen-bruce-werdschinski/

```
1. Suspend: Ctrl+z
2. Resume: bg
3. Disown: disown %1
4. Launch screen
5. Find pid: prep BLAH
6. Reparent process: reptyr ###
```

### count uinque values in a column and put in a new 

https://www.unix.com/unix-for-beginners-questions-and-answers/270526-awk-count-unique-element-array.html

```
# input
blabla_1 A,B,C,C
blabla_2 A,E,G
blabla_3 R,Q,A,B,C,R,Q

# output
blabla_1 3
blabla_2 3
blabla_3 5


awk '{split(x,C); n=split($2,F,/,/); for(i in F) if(C[F[i]]++) n--; print $1, n}' file

```

### get the promoter regions from a gtf file

https://twitter.com/David_McGaughey/status/1106371758142173185

Create TSS bed from GTF in one line: 
```bash
zcat gencode.v29lift37.annotation.gtf.gz | awk '$3=="gene" {print $0}' | grep protein_coding | awk -v OFS="\t" '{if ($7=="+") {print $1, $4, $4+1} else {print $1, $5-1, $5}}' > tss.bed
```
or 5kb flanking tss

```bash
zcat gencode.v29lift37.annotation.gtf.gz | awk '$3=="gene" {print $0}' | grep protein_coding | awk -v OFS="\t" '{if ($7=="+") {print $1, $4, $4+5000} else {print $1, $5-5000, $5}}' > promoters.bed
```
caveat: some genes are at the end of the chromosomes, add or minus 5000 may go beyond the point, use [`bedtools slop`](https://bedtools.readthedocs.io/en/latest/content/tools/slop.html) with a genome size file to avoid that.

download `fetchChromSizes` from http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/

```bash
fetchChromSizes hg19 > chrom_size.txt

zcat gencode.v29lift37.annotation.gtf.gz | awk '$3=="gene" {print $0}' |  awk -v OFS="\t" '{if ($7=="+") {print $1, $4, $4+1} else {print $1, $5-1, $5}}' | bedtools slop -i - -g chrom_size.txt -b 5000 > promoter_5kb.bed
```

### reverse one column of a txt file

reverse column 3 and put it to column5
```bash
awk -v OFS="\t" '{"echo "$3 "| rev" | getline $5}{print $0}' 

#or use perl reverse second column
perl -lane 'BEGIN{$,="\t"}{$rev=reverse $F[2];print $F[0],$F[1],$rev,$F[3]}
```

### get the full path of a file

```bash
realpath file.txt
readlink -f file.txt 
```

### pugz unizp in parallel

https://github.com/Piezoid/pugz

Contrary to the pigz program which does single-threaded decompression (see https://github.com/madler/pigz/blob/master/pigz.c#L232), pugz found a way to do truly parallel decompression.

### run singularity on a multi-user HPC

```bash
#! /bin/bash
set -euo pipefail

module load singularity
# Need a unique /tmp for this job for /tmp/rstudio-rsession & /tmp/rstudio-server
WORKDIR=/liulab/${USER}/singularity_images
mkdir -m 700 -p ${WORKDIR}/tmp2
mkdir -m 700 -p ${WORKDIR}/tmp

PASSWORD='xyz' singularity exec --bind "${WORKDIR}/tmp2:/var/run/rstudio-server" --bind "${WORKDIR}/tmp:/tmp" --bind="/liulab/${USER}" geospatial_4.0.2.simg rserver --www-port 8888 --auth-none=0  --auth-pam-helper-path=pam-helper  --www-address=127.0.0.1
```

### add ServerAliveInterval 60 to avoid dropping from your ssh session

Add the following on the top of your `~/.ssh/config` to prevent drop off the ssh session

```
Host *
 ServerAliveInterval 60
 
```
I use `screen`/`tmux` and also [mosh](https://mosh.org/) as well.
