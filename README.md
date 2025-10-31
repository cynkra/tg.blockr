# tg.blockr

Interactive blocks for exploring Canton Thurgau datasets through visual interfaces.

## Overview

tg.blockr extends the blockr ecosystem with a specialized data block for accessing datasets from Canton Thurgau, Switzerland. The TG Data block provides a visual interface to load and explore all datasets available in the [tg.data](https://github.com/cynkra/tg.data) package without writing code.

tg.blockr is part of the blockr ecosystem:

- **blockr** provides blockr base packages: https://bristolmyerssquibb.github.io/blockr
- **tg.blockr** provides Canton Thurgau data blocks

## Installation

```r
# Install from GitHub
pak::pak("cynkra/tg.blockr")
pak::pak("cynkra/tg.data")
pak::pak("BristolMyersSquibb/blockr")
```

## Getting Started

The easiest way to start exploring TG datasets is with the `blockr()` function:

```r
library(blockr)
library(tg.blockr)
run_app()
```

This opens a visual interface in your web browser where you can:
- Add a TG data block
- Select from all available Thurgau datasets via dropdown
- Choose between data lake (faster) or direct internet fetch
- Add human-readable labels (when using direct fetch)
- Enable/disable data validation (when using direct fetch)
- Connect additional transformation and visualization blocks

### Setting up Data Lake Access

To use the data lake (recommended for better performance):

```r
# Set your Gitea token as an environment variable
Sys.setenv(GITEA_TOK = "your_token_here")

# Or add to your .Renviron file:
# GITEA_TOK=your_token_here
```

## Learn More

- [blockr](https://bristolmyerssquibb.github.io/blockr/) - Official blockr framework documentation
- [tg.data package](https://github.com/cynkra/tg.data) - Dataset documentation
