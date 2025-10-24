#' TG Data block for blockr
#'
#' A data block that provides access to all datasets available in the tg.data
#' package. Users can select from a dropdown of available datasets and configure
#' whether to add labels and run validation.
#'
#' @param dataset Character. The ID of the dataset to load. Should be one of the
#'   available dataset IDs (e.g., "abfall_menge_art", "energie_emiss_co2", etc.)
#' @param add_labels Logical. Whether to add human-readable labels to the data.
#'   Default is TRUE.
#' @param validate Logical. Whether to run validation on the dataset.
#'   Default is TRUE.
#' @param ... Additional arguments passed to `blockr.core::new_data_block()`
#'
#' @return A blockr data block object that can be used in blockr boards
#'
#' @examples
#' \dontrun{
#' library(blockr.core)
#' library(tg.blockr)
#'
#' # Create a block with default settings
#' block <- new_tgdata_block()
#'
#' # Create a block with a specific dataset pre-selected
#' block <- new_tgdata_block("energie_emiss_co2")
#'
#' # Use in a board
#' blockr.core::serve(new_tgdata_block("abfall_menge_art"))
#' }
#'
#' @export
new_tgdata_block <- function(dataset = character(),
                             add_labels = TRUE,
                             validate = TRUE,
                             ...) {

  # List all available dataset IDs by finding all fetch_ functions
  list_tgdata_datasets <- function() {
    # Get all objects in tg.data namespace
    all_objs <- ls(asNamespace("tg.data"))

    # Filter for fetch_ functions and extract dataset IDs
    fetch_fns <- grep("^fetch_", all_objs, value = TRUE)
    dataset_ids <- gsub("^fetch_", "", fetch_fns)

    # Remove internal/helper functions
    dataset_ids <- setdiff(dataset_ids, c("json"))

    sort(dataset_ids)
  }

  blockr.core::new_data_block(
    server = function(id) {
      shiny::moduleServer(
        id,
        function(input, output, session) {

          dat <- shiny::reactiveVal(dataset)
          add_lab <- shiny::reactiveVal(add_labels)
          val <- shiny::reactiveVal(validate)

          shiny::observeEvent(input$dataset, dat(input$dataset))
          shiny::observeEvent(input$add_labels, add_lab(input$add_labels))
          shiny::observeEvent(input$validate, val(input$validate))

          list(
            expr = shiny::reactive({
              # Only generate expression if a dataset is selected
              if (length(dat()) && nchar(dat()) > 0) {
                bquote(
                  tg.data::get_dataset(
                    .(dataset_id),
                    add_labels = .(add_lab),
                    validate = .(val)
                  ),
                  list(
                    dataset_id = dat(),
                    add_lab = add_lab(),
                    val = val()
                  )
                )
              } else {
                quote(data.frame())
              }
            }),
            state = list(
              dataset = dat,
              add_labels = add_lab,
              validate = val
            )
          )
        }
      )
    },
    ui = function(id) {
      shiny::tagList(
        shiny::selectInput(
          inputId = shiny::NS(id, "dataset"),
          label = "Dataset",
          choices = list_tgdata_datasets(),
          selected = dataset
        ),
        shiny::checkboxInput(
          inputId = shiny::NS(id, "add_labels"),
          label = "Add labels (bfsnr_name, kategorie_name)",
          value = add_labels
        ),
        shiny::checkboxInput(
          inputId = shiny::NS(id, "validate"),
          label = "Validate data",
          value = validate
        )
      )
    },
    class = "tgdata_block",
    ...
  )
}

# Package hook to register the block on load
.onLoad <- function(libname, pkgname) {
  # Only register if blockr.core is available
  if (requireNamespace("blockr.core", quietly = TRUE)) {
    tryCatch(
      {
        # Use string-based registration to specify the package
        blockr.core::register_block(
          ctor = "new_tgdata_block",
          name = "TG Data",
          description = "Load datasets from Canton Thurgau, Switzerland",
          uid = "tgdata_block",
          category = "data",
          package = "tg.blockr",
          overwrite = TRUE
        )
      },
      error = function(e) {
        # Silently ignore errors during package development/build
        invisible(NULL)
      }
    )
  }
}
