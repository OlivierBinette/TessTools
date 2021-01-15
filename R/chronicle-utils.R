#' Download Duke Chronicle's ZIP file of JPGs
#'
#' Download ZIP file of JPG newspaper scans for the specified edition. All Chronicle issues are listed in the `chronicle_meta` data file with identifiers under the "local_id" column.
#'
#' @usage download_chronicle(id, outputdir=".", overwrite=FALSE, filename=NULL)
#'
#' @param id identifier of the chronicle issue. Valid identifiers are under the column "local_id" in the `chronicle_meta` data file.
#' @param outputdir output directory for the ZIP file.
#' @param overwrite whether or not to overwrite data which has already been downloaded.
#' @param filename name of the ZIP file. Default is NULL, in which case the ZIP file will be named after the issue id.
#'
#' @import rvest assert
#' @export
download_chronicle <- function(id, outputdir=".", overwrite=FALSE, filename=NULL) {
  assert(dir.exists(outputdir))

  if (is.null(filename)) {
    filename = paste0(id, ".zip")
  }

  file = file.path(outputdir, filename)
  if (overwrite | !file.exists(file)) {
    url = paste0("https://repository.duke.edu/dc/dukechronicle/", id)
    session = rvest::html_session(url)
    form = rvest::html_form(session)[[3]] # Unnamed form for ZIP file download.
    res = suppressWarnings(rvest::submit_form(session, form))

    writeBin(res$response$content, con=file)
  }

  return(file)
}
