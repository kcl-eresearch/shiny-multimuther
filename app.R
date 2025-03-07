library(shiny)
library(readxl)
library(dplyr)
source("tableModule.R")

## Read data ------------------------------------------------------------------

sheets <- paste0("S", c(2, 5, 6:9))
sheets_with_extra_header_rows <- paste0("S", c(10, 11, 12, 13))

table_list <- lapply(sheets, function(s) {
  readxl::read_excel("../data/MM_SupplementaryTables.xlsx", sheet = s)
}) %>% setNames(tolower(paste0("table_", sheets)))

tables_with_extra_header_rows <- lapply(sheets_with_extra_header_rows, function(s) {
  tab <- readxl::read_excel(
    "../data/MM_SupplementaryTables.xlsx",
    sheet = s,
    skip = 1,
    .name_repair = "minimal"
  )
  names(tab)[6:9] <- paste(names(tab)[6:9], "(first visit)")
  names(tab)[10:13] <- paste(names(tab)[10:13], "(last visit)")
  return(tab)
}) %>% setNames(tolower(paste0("table_", sheets_with_extra_header_rows)))

table_list <- c(table_list, tables_with_extra_header_rows)

## Prepare defaults -----------------------------------------------------------

unique_genes <- sort(unique(table_list$table_s2$Gene))
all_column_names <- names(table_list$table_s2)
default_columns <- c(
  "GencodeID",
  "Gene",
  "Beta",
  "SE",
  "Pvalue_Fixed",
  "FDR_Fixed (BH)",
  "FDR_RandomSlope (BH)",
  "FDR_RandomSlopeOnly",
  "Population level Change over time",
  "Individual-specific change over time"
)

## Define UI ------------------------------------------------------------------

ui <- navbarPage(
  title = "MultiMuTHER Study",
  
  tabPanel(title = "Genes",
    sidebarLayout(
      sidebarPanel(
        # select genes
        selectizeInput(
          "gene_name",
          "Filter by gene name",
          selected = NULL,
          choices = NULL,
          multiple = TRUE
        ),
        # select columns to show
        checkboxGroupInput(
          "show_cols",
          "Columns to show (Table S2)",
          all_column_names,
          selected = default_columns
        ),
        width = 2
      ),
      
      # Show the data tables
      mainPanel(
        tableUI("table_s2"),
        
        HTML("<br><br>"),
        tableUI("table_s6"),
        
        HTML("<br><br>"),
        tableUI("table_s8"),
        
        HTML("<br><br>"),
        tableUI("table_s10"),
        
        HTML("<br><br>"),
        tableUI("table_s12"),
        
        HTML("<br><br>"),
        
      ))),
  
  tabPanel(title = "Metabolites"),
  )

## Define server logic --------------------------------------------------------

server <- function(input, output, session) {
  updateSelectizeInput(
    session,
    "gene_name",
    choices = unique_genes,
    selected = NULL,
    server = TRUE
  )
  
  tableServer("table_s2",
              table_list[["table_s2"]],
              reactive(input$gene_name),
              reactive(input$show_cols))
  tableServer("table_s6", table_list[["table_s6"]], reactive(input$gene_name))
  tableServer("table_s8", table_list[["table_s8"]], reactive(input$gene_name))
  tableServer("table_s10", table_list[["table_s10"]], reactive(input$gene_name))
  tableServer("table_s12", table_list[["table_s12"]], reactive(input$gene_name))
}

## Run the application --------------------------------------------------------
shinyApp(ui = ui, server = server)
