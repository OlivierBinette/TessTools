
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TessTools: Tools for the use of Tesseract OCR in R

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

Interface to the Tesseract OCR command line tool and parsing functions.
This is under development.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("OlivierBinette/TessTools")
```

## Example

Run Tesseract OCR on newspaper scans. Extract paragraph text and
bounding boxes.

``` r
library(TessTools)
#> Warning: replacing previous import 'readr::guess_encoding' by
#> 'rvest::guess_encoding' when loading 'TessTools'
#> Warning: replacing previous import 'purrr::pluck' by 'rvest::pluck' when loading
#> 'TessTools'

# Run Tesseract OCR and get hocr output file paths.
outputfiles = hocr_from_zip("data-raw/dchnp71001.zip", outputdir="data-raw")
#> Running tesseract-OCR on 4 image files.

# Extract paragraph text from the first page.
text = paragraphs(outputfiles[[1]])
tail(text)
#> # A tibble: 6 x 5
#>   bbox1 bbox2 bbox3 bbox4 text                                                  
#>   <chr> <chr> <chr> <chr> <chr>                                                 
#> 1 4001  5810  4872  6309  "ural forces to do the work which we would make cheap…
#> 2 4221  6182  4872  6455  "forces of our we under I answer unhesitatingly,"     
#> 3 4006  6327  4874  6729  "labor, which should take? educate and train our own …
#> 4 4008  6770  4924  7554  "At Whitney there is being .de veloped a water power …
#> 5 4159  7573  4725  7621  "(Continued on third page.)"                          
#> 6 0     0     5150  8000  ""
```
