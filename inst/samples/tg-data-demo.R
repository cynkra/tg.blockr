# TG Data Block Demo
#
# This example demonstrates how to use the tg.blockr package to explore
# Canton Thurgau datasets through an interactive blockr interface.

# Load required libraries
library(blockr.core)
library(blockr.md)
library(blockr.dplyr)
library(blockr.ggplot)
library(tg.blockr)

# Launch interactive workflow for exploring CO2 emissions data
blockr.core::serve(
  blockr.md::new_md_board(
    blocks = c(
      # Load TG dataset - uses data lake by default (faster)
      data = new_tgdata_block(
        dataset = "energie_emiss_co2",
        use_data_lake = TRUE  # Default: load from data lake (faster)
      ),

      # Filter to recent years
      recent = new_filter_expr_block(
        exprs = "jahr >= 2010"
      ),

      # Select key columns
      selected = new_select_block(
        columns = c("jahr", "bfsnr_label", "co2_tonnen")
      ),

      # Calculate summary statistics by municipality
      summary = new_summarize_block(
        exprs = list(
          total_co2 = "sum(co2_tonnen, na.rm = TRUE)",
          avg_co2 = "mean(co2_tonnen, na.rm = TRUE)",
          years = "n()"
        ),
        by = "bfsnr_label",
        unpack = FALSE
      ),

      # Sort by total emissions
      sorted = new_arrange_block(
        columns = list(
          list(column = "total_co2", direction = "desc")
        )
      ),

      # Get top 10 municipalities
      top_municipalities = new_slice_block(
        type = "head",
        n = 10
      )
    ),
    links = c(
      # Connect the data flow
      new_link("data", "recent", "data"),
      new_link("recent", "selected", "data"),
      new_link("selected", "summary", "data"),
      new_link("summary", "sorted", "data"),
      new_link("sorted", "top_municipalities", "data")
    ),
    document = c(
      "## TG Data Block Demo\n\n",
      "This workflow demonstrates the `new_tgdata_block()` for exploring Canton Thurgau datasets.\n\n",
      "The workflow:\n\n",
      "1. **Loads** CO2 emissions data from Canton Thurgau\n",
      "   - Uses the TG Data block to access `energie_emiss_co2` dataset\n",
      "   - Loads from data lake (faster) using `tg.plot::get_data()`\n",
      "   - Toggle 'Use data lake' to compare with direct internet fetch\n",
      "2. **Filters** to recent years (2010 onwards)\n",
      "3. **Selects** key columns: year, municipality, CO2 emissions\n",
      "4. **Summarizes** emissions by municipality\n",
      "   - Total CO2 emissions\n",
      "   - Average annual emissions\n",
      "   - Number of years in data\n",
      "5. **Sorts** municipalities by total emissions (descending)\n",
      "6. **Slices** to show top 10 municipalities\n\n",

      "### Available Datasets\n\n",
      "The TG Data block provides access to all datasets in the tg.data package:\n\n",
      "- Energy consumption and emissions data\n",
      "- Waste management statistics\n",
      "- Heating system information\n",
      "- Renewable energy production\n",
      "- Agricultural land use\n",
      "- And more...\n\n",

      "### Data Lake vs Direct Fetch\n\n",
      "The TG Data block supports two data loading methods:\n\n",
      "- **Data Lake** (default): Loads pre-processed parquet files via `tg.plot::get_data()`\n",
      "  - Significantly faster\n",
      "  - Requires GITEA_TOK environment variable\n",
      "  - Pre-processed and validated\n",
      "- **Direct Fetch**: Loads from original sources via `tg.data::get_dataset()`\n",
      "  - Fetches from TG OGD API, Monithur, etc.\n",
      "  - Allows custom label addition and validation\n",
      "  - Useful for comparing data sources\n\n",

      "### Try It Yourself\n\n",
      "1. Click on the **data** block to select a different dataset\n",
      "2. Toggle **Use data lake** to compare loading methods\n",
      "3. Modify the filter conditions in the **recent** block\n",
      "4. Add more transformation blocks using the '+' button\n",
      "5. Connect blocks by dragging between them\n\n",

      "## Top 10 Municipalities by CO2 Emissions\n\n",
      "![](blockr://top_municipalities)\n\n"
    )
  )
)
