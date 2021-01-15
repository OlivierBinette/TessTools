
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TessTools: Tools for the use of Tesseract OCR in R

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

Interface to the Tesseract OCR command line tool (version 4) and parsing
functions for the analysis of historical newspaper archives. This is
under development.

## Installation

Make sure you have the
[tesseract](https://github.com/tesseract-ocr/tesseract) command line
program installed and available in PATH. You can either [Install
Tesseract via pre-built binary
package](https://tesseract-ocr.github.io/tessdoc/Home.html) or [build it
from source](https://tesseract-ocr.github.io/tessdoc/Compiling.html).

``` bash
$ tesseract
Usage:
  tesseract --help | --help-extra | --version
  tesseract --list-langs
  tesseract imagename outputbase [options...] [configfile...]
```

You can install the development version of `TessTools` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("OlivierBinette/TessTools")
```

## Example

Download the first issue (1905) of the Duke Chronicle newspaper.

``` r
library(TessTools)

issueID = chronicle_meta[1, "local_id"]
zipfile = download_chronicle(issueID, outputdir="data-raw")
```

Now we run Tesseract OCR on the newspaper scans and extract text
paragraphs together with their bounding boxes.

``` r
hocrfiles = hocr_from_zip(zipfile, outputdir="data-raw/hocr", exdir="data-raw/img")
#> Running tesseract-OCR on 4 image files.

# Extract paragraph text
text = paragraphs(hocrfiles)
tail(text[[1]]) # First page
```

<div class="kable-table">

| bbox1 | bbox2 | bbox3 | bbox4 | text                                                                                                                                                                                                                                                                                                                                                           |
| :---- | :---- | :---- | :---- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4007  | 6399  | 4134  | 6440  | take?                                                                                                                                                                                                                                                                                                                                                          |
| 4007  | 6478  | 4170  | 6512  | educat                                                                                                                                                                                                                                                                                                                                                         |
| 4006  | 6400  | 4874  | 6729  | I answer unhesitatingly, and train our own people to develop and use the water pow ers rather than import any alien race for labor.                                                                                                                                                                                                                            |
| 4008  | 6770  | 4924  | 7554  | At Whitney there is being de veloped a water power which will yield over forty thousand horse power. This is the equivalent of 320,000 coolies.. As long as we depended on slave labor our im mense natutal resources and forces remained undeveloped and use less.) Now that we are relying upon free and independent. white . labor again and that the com e |
| 4159  | 7573  | 4725  | 7621  | (Continued on third page. )                                                                                                                                                                                                                                                                                                                                    |
| 0     | 0     | 5150  | 8000  |                                                                                                                                                                                                                                                                                                                                                                |

</div>

Visualize the result using [hocrjs](https://github.com/kba/hocrjs):

``` r
webpages = visualize_html(hocrfiles, outputdir="data-raw/html") # webpage is at data-raw/html/dchnp71001-html
browseURL(webpages[[1]]) # Note: bring up the hocrjs menu and select "show background image"
```

![](hocrjs.png)

## Ground truth

Paragraphs of the first issue have been annotated according to the
article to which they belong.

``` r
# Ground truth for first page
vol1_paragraphs_truth[[1]][9:11, ]
```

<div class="kable-table">

|    | bbox1 | bbox2 | bbox3 | bbox4 | text                                                         | articleID | category | note |
| :- | ----: | ----: | ----: | ----: | :----------------------------------------------------------- | --------: | :------- | :--- |
| 9  |   481 |  1251 |  1099 |  1314 | HESPERIAN VS. COLUMBIAN.                                     |         1 | title    |      |
| 10 |   361 |  1394 |  1225 |  1554 | Sixteenth Annual Inter-Society Debate —Won By the Hesperian. |         1 | title    |      |
| 11 |   424 |  1592 |   822 |  1653 | A great debate\!                                             |         1 | text     |      |

</div>
