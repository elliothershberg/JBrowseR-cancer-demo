library(shiny)
library(JBrowseR)

ui <- fluidPage(
  titlePanel("SKBR3 PacBio Data"),
  JBrowseROutput("browserOutput")
)

server <- function(input, output, session) {
  hg19 <- assembly(
    "https://jbrowse.org/genomes/hg19/fasta/hg19.fa.gz",
    bgzip = TRUE,
    aliases = c("GRCh37"),
    refname_aliases = "https://s3.amazonaws.com/jbrowse.org/genomes/hg19/hg19_aliases.txt"
  )

  refseq <- track_feature(
    "https://s3.amazonaws.com/jbrowse.org/genomes/hg19/GRCh37_latest_genomic.sort.gff.gz",
    hg19
  )

  pacbio <- track_alignments(
    "https://s3.amazonaws.com/jbrowse.org/genomes/hg19/skbr3/reads_lr_skbr3.fa_ngmlr-0.2.3_mapped.down.bam",
    hg19
  )

  track_list <- tracks(refseq, pacbio)

  default_session <- default_session(
    hg19,
    c(refseq, pacbio)
  )

  output$browserOutput <- renderJBrowseR(
    JBrowseR("View",
             assembly = hg19,
             tracks = track_list,
             location = "chr14:50,234,326-50,249,909",
             defaultSession = default_session
    )
  )
}

shinyApp(ui, server)
