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
    cols <- names(data)[names(data) %in% cols]
    
    df <- data %>%
      dplyr::select(any_of(cols))
  }
  return(df)
}


get_cols_to_format <- function(data, pattern){
  columns <- names(data)
  columns[stringr::str_detect(columns, pattern = pattern)]
}

tableUI <- function(id, all_cols, default_cols = NULL){
  table_info_filename <- paste0("text/desc_", id, ".md")
  
  if (is.null(default_cols)){
    default_cols <- all_cols
  }
  
  col_select <- virtualSelectInput(
      inputId = NS(id, "cols"),
      label = "Columns to show",
      choices = all_cols,
      selected = default_cols,
      multiple = TRUE,
      width = "100%",
      dropboxWrapper = "body"
    ) %>% helper(content = id)
  
  tagList(includeMarkdown(table_info_filename),
          col_select,
          DT::DTOutput(NS(id, "table"))
          )
}

tableServer <- function(id, data, row_id = reactive(NULL), id_column_name = NULL){
  stopifnot(is.reactive(row_id))
  stopifnot(!is.reactive(data))
  stopifnot(!is.reactive(id_column_name))
  
  moduleServer(id, function(input, output, session){
    filtered_data <- reactive({
      filter_by_row(data, id_column_name, row_id()) %>% 
        filter_by_column(input$cols)
      })
    
    output$table <- DT::renderDT({
      cols_to_format <- get_cols_to_format(filtered_data(), pattern = "SE|Beta|FDR|Pvalue|P-value")
      signif_digit_js <- JS(
        "function(row, data) {",
        "for (i = 1; i < data.length; i++) {",
        "if (data[i]<0.001 && data[i] > 0){",
        "$('td:eq('+i+')', row).html(data[i].toExponential(2));",
        "}",
        "}",
        "}")

      dt <- DT::datatable(filtered_data(), 
                          filter = "top",
                          extensions = "Buttons",
                          options = list(dom = 'frtipB', buttons = c('csv', 'excel'),
                                         rowCallback = signif_digit_js)) %>%
        formatSignif(cols_to_format, digits = 3)

      if ("Gene" %in% names(filtered_data())){
        dt <- formatStyle(dt, "Gene", fontStyle = "italic")
      }
      dt
      })

})
}