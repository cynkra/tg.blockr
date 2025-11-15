#' TG Data block for blockr
#'
#' A data block that provides access to all datasets available in the tg.data
#' package. Users can select from a dropdown of available datasets and configure
#' whether to add labels and run validation. Optionally, data can be loaded from
#' the data lake (faster) using tg.plot::get_data() instead of fetching directly
#' from the internet via tg.data::get_dataset().
#'
#' @param dataset Character. The ID of the dataset to load. Should be one of the
#'   available dataset IDs (e.g., "abfall_menge_art", "energie_emiss_co2", etc.)
#' @param use_data_lake Logical. Whether to load data from the data lake using
#'   tg.plot::get_data() (faster). If FALSE, data is fetched directly from the
#'   internet using tg.data::get_dataset(). Default is TRUE.
#' @param add_labels Logical. Whether to add human-readable labels to the data.
#'   Only used when use_data_lake is FALSE. Default is TRUE.
#' @param validate Logical. Whether to run validation on the dataset.
#'   Only used when use_data_lake is FALSE. Default is TRUE.
#' @param ... Additional arguments passed to `blockr.core::new_data_block()`
#'
#' @return A blockr data block object that can be used in blockr boards
#'
#' @details
#' When use_data_lake is TRUE, the block uses tg.plot::get_data() to load
#' pre-processed parquet files from the data lake. This is significantly faster
#' than fetching and processing data from the internet. The data lake requires
#' the GITEA_TOK environment variable to be set.
#'
#' When use_data_lake is FALSE, the block uses tg.data::get_dataset() to fetch
#' data directly from the original sources (TG OGD API, Monithur, etc.). This
#' allows comparing the two data sources and using the add_labels and validate
#' options.
#'
#' @examples
#' \dontrun{
#' library(blockr.core)
#' library(tg.blockr)
#'
#' # Create a block with default settings (uses data lake)
#' block <- new_tgdata_block()
#'
#' # Create a block that fetches from internet
#' block <- new_tgdata_block("energie_emiss_co2", use_data_lake = FALSE)
#'
#' # Use in a board
#' blockr.core::serve(new_tgdata_block("abfall_menge_art"))
#' }
#'
#' @export
new_tgdata_block <- function(dataset = character(),
                             use_data_lake = TRUE,
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
          use_lake <- shiny::reactiveVal(use_data_lake)
          add_lab <- shiny::reactiveVal(add_labels)
          val <- shiny::reactiveVal(validate)

          shiny::observeEvent(input$dataset, dat(input$dataset))
          shiny::observeEvent(input$use_data_lake, use_lake(input$use_data_lake))
          shiny::observeEvent(input$add_labels, add_lab(input$add_labels))
          shiny::observeEvent(input$validate, val(input$validate))

          list(
            expr = shiny::reactive({
              # Only generate expression if a dataset is selected
              if (length(dat()) && nchar(dat()) > 0) {
                if (use_lake()) {
                  # Use data lake (faster)
                  bquote(
                    tg.plot::get_data(.(dataset_id)),
                    list(dataset_id = dat())
                  )
                } else {
                  # Fetch directly from internet
                  # Note: Requires tg.data with namespace fix (>= 0.0.0.9028)
                  # for get_dataset() to work when called from external packages
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
                }
              } else {
                quote(data.frame())
              }
            }),
            state = list(
              dataset = dat,
              use_data_lake = use_lake,
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
          inputId = shiny::NS(id, "use_data_lake"),
          label = "Use data lake (faster, requires GITEA_TOK)",
          value = use_data_lake
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

#' Launch blockr interface for TG data exploration
#'
#' Starts a blockr Shiny application with the TG data block pre-loaded.
#' This function automatically loads the required blockr packages
#' (blockr.core, blockr.md, blockr.dplyr, blockr.ggplot) and creates a board
#' with a TG data block as the starting point.
#'
#' @param ... Additional arguments passed to `blockr.core::serve()`
#'
#' @return A Shiny app object
#'
#' @examples
#' \dontrun{
#' library(tg.blockr)
#'
#' # Launch the blockr interface with TG data block
#' blockr()
#'
#' # Launch with custom options
#' blockr(port = 8080)
#' }
#'
#' @export
blockr <- function(...) {
  # Check if blockr.md is available (it depends on blockr.core)
  if (!requireNamespace("blockr.md", quietly = TRUE)) {
    stop(
      "Package 'blockr.md' is required but not installed. ",
      "Install it with: pak::pak('BristolMyersSquibb/blockr.md')",
      call. = FALSE
    )
  }

  if (!requireNamespace("blockr.dplyr", quietly = TRUE)) {
    cli::cli_warn(
      "Package 'blockr.dplyr' is not installed. ",
      "Install it with: pak::pak('BristolMyersSquibb/blockr.dplyr')"
    )
  }

  if (!requireNamespace("blockr.ggplot", quietly = TRUE)) {
    cli::cli_warn(
      "Package 'blockr.ggplot' is not installed. ",
      "Install it with: pak::pak('BristolMyersSquibb/blockr.ggplot')"
    )
  }

  # Load the packages quietly
  suppressPackageStartupMessages({
    # Load blockr.md first (brings in blockr.core)
    library(blockr.md)
    # Load additional blockr packages for transforms and plots
    library(blockr.dplyr)
    library(blockr.ggplot)
  })

  # Create an MD board with the TG data block
  board <- blockr.md::new_md_board(
    blocks = new_tgdata_block()
  )

  # Serve the board
  blockr.core::serve(board, ...)
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
          category = "input",
          icon = "database",
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
