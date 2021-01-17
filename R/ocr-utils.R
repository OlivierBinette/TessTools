#' Runs tesseract-OCR on the given image files.
#'
#' This function performs a system call to the tesseract command line tool, running tesseract-OCR on the given images.
#'
#' @usage hocr_from_images(imgfiles, outputdir=here(), silent=FALSE, options="")
#'
#' @param imgfiles list of image file paths. Image format should be compatible with tesseract as configured on the user's system. JPEG and PNG files are generally compatible.
#' @param outputdir directory where to store the output hocr files.
#' @param silent whether or not to supress messages (default is FALSE).
#' @param options additional options to pass to the tesseract command line tool. E.g. options="--psm 1" will use page segmentation mode one.
#'
#' @return List of output hocr file paths.
#'
#' @import parallel here
#' @export
hocr_from_images <- function(imgfiles, outputdir=".", silent=FALSE, options="") {

  if (!dir.exists(outputdir)) dir.create(outputdir)
  imgnames = basename(tools::file_path_sans_ext(imgfiles))
  n = length(imgfiles)

  ncores = min(n, parallel::detectCores())
  if (!silent) {
    cat(crayon::green("Running tesseract-OCR on", length(imgfiles), "image files.\n"))
  }
  parallel::mclapply(1:n, function(i) {
    cmd = paste("tesseract",
                normalizePath(imgfiles[[i]]),
                file.path(outputdir, imgnames[[i]]),
                "configs/chronicle",
                options)
    system(cmd, wait=TRUE, ignore.stdout=silent)
  }, mc.cores = parallel::detectCores(), mc.preschedule = FALSE)

  return(file.path(outputdir, paste0(imgnames, ".hocr")))
}

#' Run tesseract OCR on a zipped set of images.
#'
#' This function unzips images and performs a system call to the tesseract command line tool, running tesseract-OCR on the given images.
#'
#' @param zipped path to zip file containing images.
#' @param outputdir directory where to store the output hocr files.
#' @param exdir directory where images are extracted to. Set to NULL to extract image in a temporary folder.
#' @param silent whether or not to supress messages (default is FALSE).
#' @param options additional options to pass to the tesseract command line tool. E.g. options="--psm 1" will use page segmentation mode one.
#'
#' @return List of output hocr file paths.
#'
#' @import tools here crayon parallel assert utils
#' @export
hocr_from_zip <- function(zipped, outputdir=".", exdir=NULL, silent=FALSE, options="") {
  assert(file.exists(zipped))

  if (is.null(exdir)) {
    exdir = file.path(tempdir(), "exdir")
    purge = TRUE
  } else purge = FALSE

  if (!dir.exists(exdir)) dir.create(exdir)

  imgfiles = unzip(zipped, exdir=exdir)
  res = hocr_from_images(imgfiles, outputdir=outputdir, silent=silent, options=options)

  if (purge) unlink(exdir, recursive=TRUE)

  return(res)
}

#' In-browser visualization of hocr files
#'
#' This function creates an html file which can be opened in the browser and which showcases the hocr output using hocrjs.
#'
#' @usage visualize_html(hocr_files, outputdir=".")
#'
#' @param hocr_files list of  hocr file paths to visualize.
#' @param outputdir directory where to store the viewable html. This html file has the same name as the hocr file and can be opened in any browser.
#'
#' @import readr stringi
#' @export
visualize_html <- function(hocr_files, outputdir=".") {
  assert(file.exists(hocr_files))
  if (!dir.exists(outputdir)) dir.create(outputdir)

  filenames = paste0(basename(tools::file_path_sans_ext(hocr_files)), ".html")
  filepaths = file.path(outputdir, filenames)

  sapply(1:length(hocr_files), function(i) {
    txt = readr::read_file(hocr_files[[i]])
    txt = stringi::stri_replace(txt, '<script src="https://unpkg.com/hocrjs"></script></body>', regex='</body>')
    cat(txt, file=filepaths[[i]])
  })

  return(filepaths)
}

#' Extract text paragraphs and bounding boxes from hocr file.
#'
#' Contructs a dataframe containing paragraphs and bounding boxes from an hocr file created by tesseract-OCR.
#'
#' @usage paragraphs(hocr_files)
#'
#' @param hocr_files list of paths to hocr file.
#'
#' @return dataframe with columns "bbox1", "bbox2", "bbox3", "bbox4" and "text" for the four corners of the paragraph bounding box and the text content.
#'
#' @import xml2 rvest stringr stringi dplyr purrr
#' @export
paragraphs <- function(hocr_files) {
  hocr_files %>%
    lapply(function(hocr_file) {
      hocr_file %>%
        xml2::read_html() %>%
        rvest::html_nodes(".ocr_par") %>%
        purrr::map_dfr(function(x) {
          c(bbox = strsplit(html_attrs(x)[["title"]], " ")[[1]][2:5],
            text = x %>%
              rvest::html_text() %>%
              stringi::stri_replace_all("", fixed="\n") %>%
              stringi::stri_replace_all("", fixed="- ") %>%
              stringr::str_squish())
        })
    })
}


