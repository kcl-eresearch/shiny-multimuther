library(shiny)
library(readxl)
library(dplyr)
library(BioTableModule)

## Read data ------------------------------------------------------------------

sheets <- paste0("S", c(2, 5, 8:14, 19))
sheets_with_extra_header_rows <- paste0("S", c(15:18))

table_list <- lapply(sheets, function(s) {
  tab <- readxl::read_excel("../data/MM_SupplementaryTables_20251027.xlsx", sheet = s)
  names(tab) <- names(tab) %>% 
    gsub("_", " ", .) %>%
    gsub("Pvalue", "P-value", .)
  return(tab)
    
}) %>% setNames(tolower(paste0("table_", sheets)))

tables_with_extra_header_rows <- lapply(sheets_with_extra_header_rows, function(s) {
  tab <- readxl::read_excel(
    "../data/MM_SupplementaryTables_20251027.xlsx",
    sheet = s,
    skip = 1,
    .name_repair = "minimal"
  )
  names(tab) <- names(tab) %>% 
    gsub("_", " ", .) %>%
    gsub("Pvalue", "P-value", .)
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
  "P-value Fixed",
  "BH-Adjusted P-value (Fixed)",
  "BH-Adjusted P-value (Random Slope)",
  "BH-Adjusted P-value (Random Slope Only)",
  "Population level Change over time",
  "Individual-specific change over time"
)

default_columns_s8 <- c("GencodeID", "Gene", stringr::str_subset(names(table_list$table_s8), "BH-Adjusted P-value"))

unique_metabolites <- unique(table_list$table_s5$BIOCHEMICAL)
all_column_names_metabolites <- names(table_list$table_s5)
default_columns_metabolites <- c(
  "ComponentID",
  "BIOCHEMICAL",
  "SUPER.PATHWAY",
  "SUB.PATHWAY",
  "Beta",
  "SE",
  "P-value Fixed",
  "BH-Adjusted P-value (Fixed)",
  "BH-Adjusted P-value (Random Slope)",
  "BH-Adjusted P-value (Random Slope Only)",
  "Population level Change over time",
  "Individual-specific change over time"
)


all_possible_columns <- lapply(table_list, colnames) |> 
  unname() |> unlist() |> 
  unique()
columns_to_format <- all_possible_columns[stringr::str_detect(all_possible_columns, pattern = "Beta|SE|P-value|qvalue")]

## Define custom functions ----------------------------------------------------

tableServer <- function(id, data, default_cols = NULL, gene_name_cols = NULL){
  BioTableModule::tableServer(id, data,
                              default_cols = default_cols,
                              gene_name_cols = gene_name_cols,
                              sci_format_cols = columns_to_format, 
                              sci_format_digits = 4)
}

## Define UI ------------------------------------------------------------------

ui <- navbarPage(
  title = div(),
  windowTitle = "MultiMuTHER",
  theme = bslib::bs_theme(version = 5, preset = "flatly", font_scale = 1.25),
  
  tags$script(HTML("var header = $('.navbar > .container-fluid');
header.append('<div style=\"float:right\"><ahref=\"URL\"><img src=\"MultiMuTHERLogo.png\" alt=\"alt\" style=\"float:right;width:180px;\"> </a></div>');
    console.log(header)")
  ),
  
  tabPanel(
    title = "About",
    bslib::layout_columns(
      img(src = "MultiMuTHERLogo.png", width = "200", alt = "MultiMuTHER logo"),
      includeMarkdown("text/about.md"),
      col_widths = c(-2, 8, -2)
    )
  ),
  
  
  tabPanel(
    title = "Genes",
    
    # Show the data tables
    tabsetPanel(
      tabPanel("Longitudinal", bslib::layout_columns(
        tableUI("table_s2", helper=FALSE),
        col_widths = c(-1, 10, -1)
        )),
      
      tabPanel("Cell-type specific longitudinal GEAS", bslib::layout_columns(
        tableUI("table_s8", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Longitudinal GxT cis-eQTL interaction", bslib::layout_columns(
        tableUI("table_s9", helper=FALSE),
        col_widths =  c(-1, 10, -1)
      )),
      
      tabPanel("Time of visit", bslib::layout_columns(
        tableUI("table_s11", helper=FALSE),
        col_widths =  c(-1, 10, -1)
      )),
      
      tabPanel("Seasonality", bslib::layout_columns(
        tableUI("table_s13", helper=FALSE),
        col_widths =  c(-1, 10, -1)
      )),
      
      tabPanel("Serum PFOA", bslib::layout_columns(
        tableUI("table_s15", helper=FALSE),
        col_widths =  c(-1, 10, -1)
      )),
      
      tabPanel("Serum PFOS", bslib::layout_columns(
        tableUI("table_s17", helper=FALSE),
        col_widths =  c(-1, 10, -1)
      )),
      
      
      
      
    )
  ),
  
  tabPanel(
    title = "Metabolites",
    
    # Show the data tables
    tabsetPanel(
      tabPanel("Longitudinal", bslib::layout_columns(
        tableUI("table_s5", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Longitudinal GxT metQTL interaction",  bslib::layout_columns(
        tableUI("table_s10", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Time of visit",  bslib::layout_columns(
        tableUI("table_s12", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Seasonality",  bslib::layout_columns(
        tableUI("table_s14", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Serum PFOA",  bslib::layout_columns(
        tableUI("table_s16", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
      tabPanel("Serum PFOS",  bslib::layout_columns(
        tableUI("table_s18", helper=FALSE),
        col_widths = c(-1, 10, -1)
      )),
      
    )
  ),
  tabPanel(title = "Genes x Metabolites", tableUI("table_s19", helper=FALSE))
  
)

## Define server logic --------------------------------------------------------

server <- function(input, output, session) {
  shinyhelper::observe_helpers()
  
  updateSelectizeInput(
    session,
    "gene_name",
    choices = unique_genes,
    selected = NULL,
    server = TRUE
  )
  
  tableServer("table_s2", table_list[["table_s2"]], 
              default_cols = default_columns_genes, gene_name_cols = "Gene")
  tableServer("table_s8", table_list[["table_s8"]], gene_name_cols = "Gene",
              default_cols = default_columns_s8)
  tableServer("table_s9", table_list[["table_s9"]], gene_name_cols = "Gene")
  tableServer("table_s11", table_list[["table_s11"]], gene_name_cols = "Gene")
  tableServer("table_s13", table_list[["table_s13"]], gene_name_cols = "Gene")
  tableServer("table_s15", table_list[["table_s15"]], gene_name_cols = "Gene")
  tableServer("table_s17", table_list[["table_s17"]], gene_name_cols = "Gene")
  
  updateSelectizeInput(
    session,
    "metabolite",
    choices = unique_metabolites,
    selected = NULL,
    server = TRUE
  )
  
  tableServer("table_s5", table_list[["table_s5"]], default_cols = default_columns_metabolites)
  tableServer("table_s10", table_list[["table_s10"]])
  tableServer("table_s12", table_list[["table_s12"]])
  tableServer("table_s14", table_list[["table_s14"]])
  tableServer("table_s16", table_list[["table_s16"]])
  tableServer("table_s18", table_list[["table_s18"]])
  
  tableServer("table_s19", table_list[["table_s19"]])
}

## Run the application --------------------------------------------------------
shinyApp(ui = ui, server = server)
