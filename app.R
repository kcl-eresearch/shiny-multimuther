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
unique_genes <- sort(unique(table_s2$Gene))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("MultiMuTHER Study"),

    # Sidebar with input to select genes 
    sidebarLayout(
        sidebarPanel(
            selectizeInput("gene_name", "Filter by gene name",
                           selected = NULL, choices = NULL, multiple = TRUE)
        ),

        # Show the data table
        mainPanel(
           DT::DTOutput("table_s2")
        ),
    )
)

# Define server logic to output the table
server <- function(input, output, session) {
  
  updateSelectizeInput(session, "gene_name",
                       choices = unique_genes, selected = NULL, server = TRUE)
  
  output$table_s2 <- DT::renderDT({
    if (is.null(input$gene_name)) {
      table_s2
    } else if (length(input$gene_name) == 1 && input$gene_name == ""){
      table_s2
    } else {
      table_s2 %>% 
        dplyr::filter(Gene %in% input$gene_name)
    }
    }) 

}

# Run the application 
shinyApp(ui = ui, server = server)
