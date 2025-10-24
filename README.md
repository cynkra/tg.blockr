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
pak::pak("cynkra/blockr.core")
pak::pak("cynkra/blockr.md")
pak::pak("cynkra/blockr.dplyr")
pak::pak("cynkra/blockr.ggplot")
```

## Getting Started

Create and launch a workflow to explore TG datasets:

```r
library(blockr.core)
library(blockr.md)
library(blockr.dplyr)
library(tg.blockr)

# Create a simple workflow
serve(
  new_md_board(
    blocks = new_tgdata_block("energie_emiss_co2")
  )
)
```

This opens a visual interface in your web browser where you can:
- Select from all available Thurgau datasets via dropdown
- Choose whether to add human-readable labels
- Enable/disable data validation
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
- **Label addition**: Optionally add human-readable municipality and category names
- **Validation**: Built-in data validation to ensure integrity
- **Auto-registration**: Block automatically appears in the blockr UI

### Usage in Code

```r
# Create a TG Data block programmatically
block <- new_tgdata_block(
  dataset = "energie_emiss_co2",  # Pre-select a dataset
  add_labels = TRUE,               # Add readable labels
  validate = TRUE                  # Run validation
)

# Use in a board with transformations
serve(
  new_md_board(
    blocks = c(
      data = new_tgdata_block("abfall_menge_art"),
      filtered = new_expression_filter_block(
        expressions = list("jahr >= 2020")
      )
    ),
    links = new_link("data", "filtered", "data")
  )
)
```

## Learn More

- [tg.data package](https://github.com/cynkra/tg.data) - Dataset documentation
- [blockr.core](https://bristolmyerssquibb.github.io/blockr.core/) - Core workflow engine
- [blockr.dplyr](https://bristolmyerssquibb.github.io/blockr.dplyr/) - Data transformation blocks
- [blockr.ggplot](https://bristolmyerssquibb.github.io/blockr.ggplot/) - Visualization blocks

## License

MIT License - see [LICENSE.md](LICENSE.md) for details.
