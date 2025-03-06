#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(readxl)
library(dplyr)


table_s2 <- readxl::read_excel("../data/MM_SupplementaryTables.xlsx", sheet = "S2")
table_s6 <- readxl::read_excel("../data/MM_SupplementaryTables.xlsx", sheet = "S6")

unique_genes <- sort(unique(table_s2$Gene))
all_column_names <- names(table_s2)
default_columns <- c("GencodeID", "Gene", "Beta", "SE", "Pvalue_Fixed", "FDR_Fixed (BH)", "FDR_RandomSlope (BH)",
                     "FDR_RandomSlopeOnly", "Population level Change over time",
                     "Individual-specific change over time")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("MultiMuTHER Study"),

    # Sidebar with input to select genes 
    sidebarLayout(
        sidebarPanel(
          # select genes
          selectizeInput("gene_name", "Filter by gene name",
                         selected = NULL, choices = NULL, multiple = TRUE),
          # select columns to show
          checkboxGroupInput("show_cols", "Columns to show (Table S2)",
                             all_column_names, selected = default_columns),
          width = 2
        ),

        # Show the data tables
        mainPanel(
          includeMarkdown("text/desc_table_s2.md"),
          DT::DTOutput("table_s2"),
          
          HTML("<br><br>"),
          includeMarkdown("text/desc_table_s6.md"),
          DT::DTOutput("table_s6")
        ),
    )
)

# Define server logic to output the table
server <- function(input, output, session) {
  
  updateSelectizeInput(session, "gene_name",
                       choices = unique_genes, selected = NULL, server = TRUE)
  
  table_s2_filtered <- reactive({
    if (is.null(input$gene_name)) {
      df <- table_s2
    } else if (length(input$gene_name) == 1 && input$gene_name == ""){
      df <- table_s2
    } else {
      df <- table_s2 %>% 
        dplyr::filter(Gene %in% input$gene_name)
    }
    
    df <- df %>%
      dplyr::select(any_of(c("Gene", input$show_cols)))
    return(df)
  })
  
  table_s6_filtered <- reactive({
    if (is.null(input$gene_name)) {
      df <- table_s6
    } else if (length(input$gene_name) == 1 && input$gene_name == ""){
      df <- table_s6
    } else {
      df <- table_s6 %>% 
        dplyr::filter(Gene %in% input$gene_name)
    }
    
    return(df)
  })
  
  output$table_s2 <- DT::renderDT({
    table_s2_filtered()
    })
  
  output$table_s6 <- DT::renderDT({
    table_s6_filtered()
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
