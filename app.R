library(shiny)
library(readxl)
library(dplyr)
library(shinyhelper)
library(shinyWidgets)
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
all_column_names_genes <- names(table_list$table_s2)
default_columns_genes <- c(
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

unique_metabolites <- unique(table_list$table_s5$BIOCHEMICAL)
all_column_names_metabolites <- names(table_list$table_s5)
default_columns_metabolites <- c(
  "ComponentID",
  "BIOCHEMICAL",                         
  "SUPER.PATHWAY",
  "SUB.PATHWAY",
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
      
      # Show the data tables
      tabsetPanel(
        tabPanel("Longitudinal", 
                 # select columns to show
                 virtualSelectInput(
                   inputId = "show_cols_genes",
                   label = "Columns to show", 
                   choices = all_column_names_genes,
                   selected = default_columns_genes,
                   multiple = TRUE,
                   width = "90%",
                   dropboxWrapper = "body"
                 ) %>% helper(content = "genes_cols"),
                 tableUI("table_s2"),
                 ),
        
        tabPanel("Time of visit", tableUI("table_s6")),
        
        tabPanel("Seasonality", tableUI("table_s8")),
        
        tabPanel("Serum PFOA", tableUI("table_s10")),
        
        tabPanel("Serum PFOS", tableUI("table_s12")),
      
      )),
  
  tabPanel(title = "Metabolites",
     # sidebarLayout(
     #   sidebarPanel(
     #     # select metabolites
     #     selectizeInput(
     #       "metabolite",
     #       "Filter by metabolite",
     #       selected = NULL,
     #       choices = NULL,
     #       multiple = TRUE
     #     ),

       
       # Show the data tables
       tabsetPanel(
         tabPanel("Longitudinal", 
                      virtualSelectInput(
                        inputId = "show_cols_metabolites",
                        label = "Columns to show",
                        choices = all_column_names_metabolites,
                        selected = default_columns_metabolites,
                        multiple = TRUE,
                        width = "90%",
                        dropboxWrapper = "body"
                      ) %>% helper(content = "metabolites_cols"),
                  tableUI("table_s5")),
         
         tabPanel("Time of visit", tableUI("table_s7")),
         
         tabPanel("Seasonality", tableUI("table_s9")),
         
         tabPanel("Serum PFOA", tableUI("table_s11")),
         
         tabPanel("Serum PFOS", tableUI("table_s13")),
         
       )),
  )

## Define server logic --------------------------------------------------------

server <- function(input, output, session) {
  observe_helpers()
  
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
              id_column_name = "Gene",
              reactive(input$show_cols_genes))
  tableServer("table_s6", table_list[["table_s6"]], reactive(input$gene_name), id_column_name = "Gene")
  tableServer("table_s8", table_list[["table_s8"]], reactive(input$gene_name), id_column_name = "Gene")
  tableServer("table_s10", table_list[["table_s10"]], reactive(input$gene_name), id_column_name = "Gene")
  tableServer("table_s12", table_list[["table_s12"]], reactive(input$gene_name), id_column_name = "Gene")
  
  updateSelectizeInput(
    session,
    "metabolite",
    choices = unique_metabolites,
    selected = NULL,
    server = TRUE
  ) 
  
  tableServer("table_s5", 
              table_list[["table_s5"]], 
              reactive(input$metabolite), 
              id_column_name = "BIOCHEMICAL",
              reactive(input$show_cols_metabolites))
  tableServer("table_s7", table_list[["table_s7"]], reactive(input$metabolite), id_column_name = "BIOCHEMICAL")
  tableServer("table_s9", table_list[["table_s9"]], reactive(input$metabolite), id_column_name = "BIOCHEMICAL")
  tableServer("table_s11", table_list[["table_s11"]], reactive(input$metabolite), id_column_name = "BIOCHEMICAL")
  tableServer("table_s13", table_list[["table_s13"]], reactive(input$metabolite), id_column_name = "BIOCHEMICAL")
}

## Run the application --------------------------------------------------------
shinyApp(ui = ui, server = server)
