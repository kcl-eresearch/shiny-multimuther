filter_by_row <- function(data, column_name, id){
  if (length(id) == 1 && id == ""){
    id <- NULL
  }
  
  if (is.null(id)) {
    df <- data
  } else {
    df <- data %>% 
      dplyr::filter(.data[[column_name]] %in% id)
  }
  return(df)
}


filter_by_column <- function(data, cols){
  if (is.null(cols)) {
    df <- data
  } else {
    df <- data %>% 
      dplyr::select(any_of(cols))
  }
  return(df)
}


tableUI <- function(id){
  table_info_filename <- paste0("text/desc_", id, ".md")
  
  tagList(includeMarkdown(table_info_filename),
          DT::DTOutput(NS(id, "table"))
          )
}

tableServer <- function(id, data, row_id = reactive(NULL), id_column_name, cols = reactive(NULL)){
  stopifnot(is.reactive(row_id))
  stopifnot(!is.reactive(data))
  stopifnot(!is.reactive(id_column_name))
  
  moduleServer(id, function(input, output, session){
    filtered_data <- reactive({
      filter_by_row(data, id_column_name, row_id()) %>% 
        filter_by_column(cols())
      })
    
    output$table <- DT::renderDT(filtered_data())
})
}