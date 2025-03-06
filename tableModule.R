filter_by_gene_name <- function(data, gene_name){
  if (length(gene_name) == 1 && gene_name == ""){
    gene_name <- NULL
  }
  
  if (is.null(gene_name)) {
    df <- data
  } else {
    df <- data %>% 
      dplyr::filter(Gene %in% gene_name)
  }
  return(df)
}


tableUI <- function(id){
  
  table_info_filename <- paste0("text/desc_", id, ".md")
  
  tagList(includeMarkdown(table_info_filename),
          DT::DTOutput(NS(id, "table"))
          )
}

tableServer <- function(id, data, gene_name = reactive(NULL)){
  stopifnot(is.reactive(gene_name))
  stopifnot(!is.reactive(data))
  
  moduleServer(id, function(input, output, session){
    filtered_data <- reactive(filter_by_gene_name(data, gene_name()))
    
    output$table <- DT::renderDT(filtered_data())
})
}