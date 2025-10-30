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

## Define UI ------------------------------------------------------------------

ui <- navbarPage(
  title = div(img(src = "MultiMuTHERLogo.png", width = 150), ""),
  windowTitle = "MultiMuTHER",
  theme = bslib::bs_theme(version = 4),
  includeCSS("www/kcl_theme_slim.css"),
  
  tabPanel(
    title = "About",
    img(src = "MultiMuTHERLogo.png", width = "200", alt = "MultiMuTHER logo"),
    includeMarkdown("text/about.md")
  ),
  
  
  tabPanel(
    title = "Genes",
    
    # Show the data tables
    tabsetPanel(
      tabPanel("Longitudinal", tableUI("table_s2")),
      
      tabPanel("Time of visit", tableUI("table_s11")),
      
      tabPanel("Seasonality", tableUI("table_s13")),
      
      tabPanel("Serum PFOA", tableUI("table_s15")),
      
      tabPanel("Serum PFOS", tableUI("table_s16")),
      
    )
  ),
  
  tabPanel(
    title = "Metabolites",
    
    # Show the data tables
    tabsetPanel(
      tabPanel("Longitudinal", tableUI("table_s5")),
      
      tabPanel("Time of visit", tableUI("table_s12")),
      
      tabPanel("Seasonality", tableUI("table_s14")),
      
      tabPanel("Serum PFOA", tableUI("table_s17")),
      
      tabPanel("Serum PFOS", tableUI("table_s18")),
      
    )
  ),
  tabPanel(title = "Genes x Metabolites", tableUI("table_s19"))
  
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
  
  tableServer("table_s2", table_list[["table_s2"]])
  tableServer("table_s11", table_list[["table_s11"]])
  tableServer("table_s13", table_list[["table_s13"]])
  tableServer("table_s15", table_list[["table_s15"]])
  tableServer("table_s16", table_list[["table_s16"]])
  
  updateSelectizeInput(
    session,
    "metabolite",
    choices = unique_metabolites,
    selected = NULL,
    server = TRUE
  )
  
  tableServer("table_s5", table_list[["table_s5"]])
  tableServer("table_s12", table_list[["table_s12"]])
  tableServer("table_s14", table_list[["table_s14"]])
  tableServer("table_s17", table_list[["table_s17"]])
  tableServer("table_s18", table_list[["table_s18"]])
  
  tableServer("table_s14", table_list[["table_s14"]])
}

## Run the application --------------------------------------------------------
shinyApp(ui = ui, server = server)
