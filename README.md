# tg.blockr

Interactive blocks for exploring Canton Thurgau datasets through visual interfaces.

## Overview

tg.blockr extends the blockr ecosystem with a specialized data block for accessing datasets from Canton Thurgau, Switzerland. The TG Data block provides a visual interface to load and explore all datasets available in the [tg.data](https://github.com/cynkra/tg.data) package without writing code.

tg.blockr is part of the blockr ecosystem:
- **blockr.core** provides the workflow engine
- **blockr.md** provides markdown-based boards
- **blockr.dplyr** provides data transformation blocks
- **blockr.ggplot** provides visualization blocks
- **tg.blockr** provides Canton Thurgau data blocks

## Installation

```r
# Install from GitHub
pak::pak("cynkra/tg.blockr")
pak::pak("cynkra/tg.data")

# Install blockr dependencies
pak::pak("BristolMyersSquibb/blockr.core")
pak::pak("BristolMyersSquibb/blockr.md")
pak::pak("BristolMyersSquibb/blockr.dplyr")
pak::pak("BristolMyersSquibb/blockr.ggplot")
```

## Getting Started

The easiest way to start exploring TG datasets is with the `blockr()` function:

```r
library(tg.blockr)

# Launch interactive dashboard with TG data block
blockr()
```

This opens a visual interface in your web browser with a TG data block ready to use. You can then add transformation and visualization blocks through the UI.

> **Note**: The `blockr()` function was previously available in the tg.data package but has been moved to tg.blockr. If you previously used `tg.data::blockr()`, please use `tg.blockr::blockr()` instead.

Alternatively, create a custom workflow programmatically:

```r
library(blockr.core)
library(blockr.md)
library(blockr.dplyr)
library(tg.blockr)

# Create a workflow with a pre-selected dataset
serve(
  new_md_board(
    blocks = new_tgdata_block("energie_emiss_co2")
  )
)
```

This opens a visual interface in your web browser where you can:
- Select from all available Thurgau datasets via dropdown
- Choose between data lake (faster) or direct internet fetch
- Add human-readable labels (when using direct fetch)
- Enable/disable data validation (when using direct fetch)
- Connect additional transformation and visualization blocks

## Available Datasets

The TG Data block provides access to datasets including:

- **Energy**: consumption, CO2 emissions, heating systems
- **Waste**: collection amounts by type and municipality
- **Renewables**: solar, wind, hydro, and biomass production
- **Agriculture**: land use statistics
- And more...

All datasets follow standardized German column naming conventions with built-in type enforcement and validation.

## Example Workflow

See [inst/samples/tg-data-demo.R](inst/samples/tg-data-demo.R) for a complete example that:
1. Loads CO2 emissions data
2. Filters to recent years
3. Summarizes by municipality
4. Identifies top emitters

Run the example:

```r
source(system.file("samples/tg-data-demo.R", package = "tg.blockr"))
```

## The TG Data Block

### Features

- **Dataset selection**: Dropdown list of all available tg.data datasets
- **Data lake support**: Load from pre-processed parquet files (faster, default)
- **Direct fetch**: Alternative loading from original internet sources
- **Label addition**: Optionally add human-readable municipality and category names
- **Validation**: Built-in data validation to ensure integrity
- **Auto-registration**: Block automatically appears in the blockr UI

### Data Loading Methods

The TG Data block supports two methods for loading data:

1. **Data Lake** (default, recommended)
   - Uses `tg.plot::get_data()` to load pre-processed parquet files
   - Significantly faster than direct fetch
   - Requires `GITEA_TOK` environment variable to be set
   - Data is pre-validated and processed

2. **Direct Fetch** (uncheck "Use data lake")
   - Uses `tg.data::get_dataset()` to fetch from original sources
   - Loads from TG OGD API, Monithur, Statistik TG, etc.
   - Allows custom label addition and validation options
   - Useful for comparing data sources or getting latest updates
   - **Note**: Requires tg.data >= 0.0.0.9028 (namespace fix for external calls)

### Usage in Code

```r
# Create a TG Data block with data lake (default, faster)
block <- new_tgdata_block(
  dataset = "energie_emiss_co2",
  use_data_lake = TRUE  # Default
)

# Create a block using direct fetch
block <- new_tgdata_block(
  dataset = "energie_emiss_co2",
  use_data_lake = FALSE,
  add_labels = TRUE,
  validate = TRUE
)

# Use in a board with transformations
serve(
  new_md_board(
    blocks = c(
      data = new_tgdata_block("abfall_menge_art"),
      filtered = new_filter_expr_block(
        exprs = "jahr >= 2020"
      )
    ),
    links = new_link("data", "filtered", "data")
  )
)
```

### Setting up Data Lake Access

To use the data lake (recommended for better performance):

```r
# Set your Gitea token as an environment variable
Sys.setenv(GITEA_TOK = "your_token_here")

# Or add to your .Renviron file:
# GITEA_TOK=your_token_here
```

## Learn More

- [tg.data package](https://github.com/cynkra/tg.data) - Dataset documentation
- [blockr.core](https://bristolmyerssquibb.github.io/blockr.core/) - Core workflow engine
- [blockr.dplyr](https://bristolmyerssquibb.github.io/blockr.dplyr/) - Data transformation blocks
- [blockr.ggplot](https://bristolmyerssquibb.github.io/blockr.ggplot/) - Visualization blocks

## License

MIT License - see [LICENSE.md](LICENSE.md) for details.
