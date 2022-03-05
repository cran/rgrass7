% Copyright (C) 2005-2022 Roger S. Bivand
\name{readRAST}
\alias{readRAST}
\alias{writeRAST}
\alias{read_RAST}
\alias{write_RAST}
\title{Read and write GRASS raster files}
\description{
Read GRASS raster files from GRASS into R \pkg{sp} \code{"SpatialGridDataFrame"} or \pkg{terra} \code{"SpatRaster"} objects, and write single columns of \pkg{sp} \code{"SpatialGridDataFrame"} or \pkg{terra} \code{"SpatRaster"} objects to GRASS. \code{readRAST} and \code{writeRAST} use temporary binary files and r.out.bin and r.in.bin for speed reasons. \code{read_RAST()} and \code{write_RAST()} use \code{"RRASTER"} files written and read by GDAL. 
}



\usage{
readRAST(vname, cat=NULL, ignore.stderr = get.ignore.stderrOption(),
 NODATA=NULL, plugin=get.pluginOption(), mapset=NULL,
 useGDAL=get.useGDALOption(), close_OK=TRUE, drivername="GTiff",
 driverFileExt=NULL, return_SGDF=TRUE)
read_RAST(vname, cat=NULL, NODATA=NULL, ignore.stderr=get.ignore.stderrOption(),
 return_format="SGDF", close_OK=return_format=="SGDF", flags=NULL)
writeRAST(x, vname, zcol = 1, NODATA=NULL,
 ignore.stderr = get.ignore.stderrOption(), useGDAL=get.useGDALOption(),
 overwrite=FALSE, flags=NULL, drivername="GTiff")
write_RAST(x, vname, zcol = 1, NODATA=NULL, flags=NULL, 
 ignore.stderr = get.ignore.stderrOption(), overwrite=FALSE, verbose=TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{vname}{A vector of GRASS raster file names}
  \item{cat}{default NULL; if not NULL, must be a logical vector matching vname, stating which (CELL) rasters to return as factor}
  \item{return_format}{For \code{read_RAST()}, either \code{"SGDF"} or \code{"terra"}}
  \item{ignore.stderr}{default taking the value set by \code{set.ignore.stderrOption}; can be set to TRUE to silence \code{system()} output to standard error; does not apply on Windows platforms}
  \item{plugin}{default taking the value set by \code{set.pluginOption};
    NULL does auto-detection, changes to FALSE if vname is longer than 1, and a sanity check will be run on raster and current region, and the function will revert to FALSE if mismatch is found; if TRUE, the plugin is available and the raster should be read in its original region and resolution; if the plugin is used, no further arguments other than mapset are respected}
  \item{mapset}{default NULL, if plugin is TRUE, the mapset of the file to be imported will be autodetected; if not NULL and if plugin is TRUE, a character string overriding the autodetected mapset, otherwise ignored}
  \item{useGDAL}{(effectively defunct, only applies to use of plugin) default taking the value set by \code{set.useGDALOption}; use plugin and \code{readGDAL} if autodetected or plugin=TRUE; or for writing \code{writeGDAL}, GTiff, and r.in.gdal, if FALSE using r.out.bin or r.in.bin}
  \item{close_OK}{default TRUE - clean up possible open connections used for reading metadata; may be set to FALSE to avoid the side-effect of other user-opened connections being broken}
  \item{drivername}{default \code{"GTiff"}; a valid GDAL writable driver name to define the file format for intermediate files}
  \item{driverFileExt}{default NULL; otherwise string value of required driver file name extension}
  \item{return_SGDF}{default TRUE returning a \code{SpatialGridDataFrame} object, if FALSE, return a list with a \code{GridTopology} object, a list of bands, and a proj4string; see example below}
  \item{x}{A SpatialGridDataFrame object for export to GRASS as a raster layer, for \code{write_RAST()} a \pkg{terra} \code{"SpatRaster"} object}
  \item{zcol}{Attribute column number or name}
  \item{NODATA}{by default NULL, in which case it is set to one less than \code{floor()}of the data values, otherwise an integer NODATA value (required to be integer by GRASS r.out.bin)}
  \item{overwrite}{default FALSE, if TRUE inserts \code{"overwrite"} into the value of the \code{flags} argument if not already there to allow existing GRASS rasters to be overwritten}
  \item{flags}{default NULL, character vector, for example \code{"overwrite"}}
  \item{verbose}{default TRUE, report how writing to GRASS is specified}
%  \item{colname}{alternative name for data column if not file basename}
%  \item{integer}{logical value: TRUE if the input data is integer}
}

\value{
\code{readRAST} returns a SpatialGridDataFrame objects with an data.frame in the data slots, and with the projection argument set. Note that the projection argument set is the the GRASS rendering of proj4, and will differ from the WKT/ESRI rendering returned by readVECT in form but not meaning. They are exchangeable but not textually identical, usually with the +ellps= term replaced by ellipsoid parameters verbatim. If return_SGDF is FALSE, a list with a \code{GridTopology} object, a list of bands, and a proj4string is returned, with an S3 class attribute of \dQuote{gridList}.
}


\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no}}

\examples{
use_sp()
run <- FALSE
if (nchar(Sys.getenv("GISRC")) > 0 &&
  read.dcf(Sys.getenv("GISRC"))[1,"LOCATION_NAME"] == "nc_basic_spm_grass7") run <- TRUE
  GV <- Sys.getenv("GRASS_VERBOSE")
  Sys.setenv("GRASS_VERBOSE"=0)
#  require(rgdal)
  ois <- get.ignore.stderrOption()
  set.ignore.stderrOption(TRUE)
  get.useGDALOption()
if (run) {
  nc_basic <- readRAST(c("geology", "elevation"), cat=c(TRUE, FALSE),
    useGDAL=FALSE)
  nc_basic <- readRAST(c("geology", "elevation"), cat=c(TRUE, FALSE),
    useGDAL=TRUE)
  print(table(nc_basic$geology))
}
if (run) {
  execGRASS("r.stats", flags=c("c", "l", "quiet"), input="geology")
}
if (run) {
  boxplot(nc_basic$elevation ~ nc_basic$geology)
}
if (run) {
  nc_basic$sqdem <- sqrt(nc_basic$elevation)
}
if (run) {
  if ("GRASS" \%in\% rgdal::gdalDrivers()$name) {
    execGRASS("g.region", raster="elevation")
    dem1 <- readRAST("elevation", plugin=TRUE, mapset="PERMANENT")
    print(summary(dem1))
    execGRASS("g.region", raster="elevation")
  }
}
if (run) {
  writeRAST(nc_basic, "sqdemSP", zcol="sqdem", flags=c("quiet", "overwrite"))
  execGRASS("r.info", map="sqdemSP")
}
if (run) {
  execGRASS("g.remove", flags="f", name="sqdemSP", type="raster")
}
if (run) {
  writeRAST(nc_basic, "sqdemSP", zcol="sqdem", useGDAL=TRUE, flags=c("quiet", "overwrite"))
  execGRASS("r.info", map="sqdemSP")
}
if (run) {
  print(system.time(sqdemSP <- readRAST(c("sqdemSP", "elevation"),
    useGDAL=TRUE, return_SGDF=FALSE)))
}
if (run) {
  print(system.time(sqdemSP <- readRAST(c("sqdemSP", "elevation"),
    useGDAL=TRUE, return_SGDF=TRUE)))
}
if (run) {
  print(system.time(sqdemSP <- readRAST(c("sqdemSP", "elevation"),
    useGDAL=FALSE, return_SGDF=TRUE)))
}
if (run) {
  print(system.time(sqdemSP <- readRAST(c("sqdemSP", "elevation"),
    useGDAL=FALSE, return_SGDF=FALSE)))
}
if (run) {
  str(sqdemSP)
  mat <- do.call("cbind", sqdemSP$dataList)
  str(mat)
}
if (run) {
  print(system.time(SGDF <- sp::SpatialGridDataFrame(grid=sqdemSP$grid,
    proj4string=sqdemSP$proj4string, data=as.data.frame(sqdemSP$dataList))))
}
if (run) {
  summary(SGDF)
}
if (run) {
  execGRASS("g.remove", flags="f", name="sqdemSP", type="raster")
  execGRASS("r.mapcalc", expression="basins0 = basins - 1")
  execGRASS("r.stats", flags="c", input="basins0")
}
if (run) {
  basins0 <- readRAST("basins0")
  print(table(basins0$basins0))
}
if (run) {
  basins0 <- readRAST("basins0", plugin=FALSE)
  print(table(basins0$basins0))
}
if (run) {
  execGRASS("g.remove", flags="f", name="basins0", type="raster")
}
run <- run && require("terra", quietly=TRUE)
if (run) {
  v1 <- read_RAST("landuse", cat=TRUE, return_format="terra")
  v1
  inMemory(v1)
}
if (run) {
  write_RAST(v1, "landuse1", flags=c("o", "overwrite"))
  execGRASS("r.stats", flags="c", input="landuse1")
  execGRASS("g.remove", flags="f", name="landuse1", type="raster")
}
  Sys.setenv("GRASS_VERBOSE"=GV)
  set.ignore.stderrOption(ois)
}
\keyword{spatial}

