library(shiny)
library(DT)
library(glue)
library(readr)
library(JBrowseR)

ui <- fluidPage(
  titlePanel("SKBR3 PacBio Data"),
  dataTableOutput("gene_fusions"),
  JBrowseROutput("browserOutput")
)

server <- function(input, output, session) {
  # browser setup -----------------------------------------------------------
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

  location <- reactiveVal("chr14:50,234,326-50,249,909")

  output$browserOutput <- renderJBrowseR(
    JBrowseR("View",
             assembly = hg19,
             tracks = track_list,
             location = location(),
             defaultSession = default_session
    )
  )

  # table setup -------------------------------------------------------------
  gene_fusion_df <- reactive(read_csv("gene_fusions.csv"))

  observeEvent(input$gene_fusions_rows_selected, {
    print(input$gene_fusions_rows_selected)
    selected_row <- gene_fusion_df()[input$gene_fusions_rows_selected, ]
    print("here")
    print(selected_row)
    location(glue("{selected_row$chrom}:{selected_row$start}-{selected_row$end}"))
  })

  output$gene_fusions <- DT::renderDT(gene_fusion_df(), selection = "single")

}

shinyApp(ui, server)
