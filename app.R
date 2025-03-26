library(shiny)
library(readxl)
library(dplyr)
library(DT)
library(shinyhelper)
library(shinyWidgets)
source("tableModule.R")

## Read data ------------------------------------------------------------------

sheets <- paste0("S", c(2, 5, 6:9, 14))
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
  title = div(
    img(
      src = "MultiMuTHERLogo.png",
      width = 150
     ),
    ""
    ),
  windowTitle = "MultiMuTHER",
  theme = bslib::bs_theme(version = 4),
  includeCSS("www/kcl_theme_slim.css"),
  
  tabPanel(
    title = "About",
    img(src="MultiMuTHERLogo.png", width="200", alt = "MultiMuTHER logo"),
    includeMarkdown("text/about.md")
           ),
  
  
  tabPanel(
    title = "Genes",

    # Show the data tables
    tabsetPanel(
      tabPanel(
        "Longitudinal",
        tableUI("table_s2", all_column_names_genes, default_columns_genes)
      ),

      tabPanel("Time of visit", tableUI(
        "table_s6", all_cols = names(table_list$table_s6)
      )),

      tabPanel("Seasonality", tableUI(
        "table_s8", all_cols = names(table_list$table_s8)
      )),

      tabPanel("Serum PFOA", tableUI(
        "table_s10", all_cols = names(table_list$table_s10)
      )),

      tabPanel("Serum PFOS", tableUI(
        "table_s12", all_cols = names(table_list$table_s12)
      )),

    )
  ),
  
  tabPanel(
    title = "Metabolites",

    # Show the data tables
    tabsetPanel(
      tabPanel(
        "Longitudinal",
        tableUI(
          "table_s5",
          all_column_names_metabolites,
          default_columns_metabolites
        )
      ),

      tabPanel("Time of visit", tableUI(
        "table_s7", all_cols = names(table_list$table_s7)
      )),

      tabPanel("Seasonality", tableUI(
        "table_s9", all_cols = names(table_list$table_s9)
      )),

      tabPanel("Serum PFOA", tableUI(
        "table_s11", all_cols = names(table_list$table_s11)
      )),

      tabPanel("Serum PFOS", tableUI(
        "table_s13", all_cols = names(table_list$table_s13)
      )),

    )
  ),
  tabPanel(
    title = "Genes x Metabolites",
    tableUI(
      "table_s14", all_cols = names(table_list$table_s14)
    )
  )
  
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
              table_list[["table_s2"]])
  tableServer("table_s6", table_list[["table_s6"]])
  tableServer("table_s8", table_list[["table_s8"]])
  tableServer("table_s10", table_list[["table_s10"]])
  tableServer("table_s12", table_list[["table_s12"]])
  
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
              id_column_name = "BIOCHEMICAL")
  tableServer("table_s7", table_list[["table_s7"]])
  tableServer("table_s9", table_list[["table_s9"]])
  tableServer("table_s11", table_list[["table_s11"]])
  tableServer("table_s13", table_list[["table_s13"]])
  
  tableServer("table_s14", table_list[["table_s14"]])
}

## Run the application --------------------------------------------------------
shinyApp(ui = ui, server = server)
