% Copyright (C) 2005-2010 Roger S. Bivand
%
\name{readVECT}
\alias{readVECT}
\alias{writeVECT}
\alias{vInfo}
\alias{vColumns}
\alias{vDataCount}
\alias{vect2neigh}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Read and write GRASS 7 vector object files}
\description{
  \code{readVECT} moves one GRASS 7 vector object file with attribute data through a temporary shapefile to a Spatial*DataFrame object of type determined by the GRASS 7 vector object; \code{writeVECT} moves a Spatial*DataFrame object through a temporary shapefile to a GRASS vector object file. \code{vect2neigh} returns neighbour pairs with shared boundary length as described by Markus Neteler, in \url{https://stat.ethz.ch/pipermail/r-sig-geo/2005-October/000616.html}. \code{cygwin_clean_temp} can be called to try to clean the GRASS mapset-specific temporary directory under cygwin.
}
\usage{
readVECT(vname, layer, type=NULL, plugin=NULL,
 remove.duplicates = TRUE, ignore.stderr=NULL,
 with_prj=TRUE, with_c=FALSE, mapset=NULL,
 pointDropZ=FALSE, driver=NULL)
writeVECT(SDF, vname,  v.in.ogr_flags=NULL,
 ignore.stderr = NULL, driver=NULL,
 min_area=0.0001, snap=-1)
vInfo(vname, layer, ignore.stderr = NULL)
vColumns(vname, layer, ignore.stderr = NULL)
vDataCount(vname, layer, ignore.stderr = NULL)
vect2neigh(vname, ID=NULL, ignore.stderr = NULL, remove=TRUE, vname2=NULL,
 units="k")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{vname}{A GRASS 7 vector file name}
  \item{layer}{a layer name (string); if missing set to default of \dQuote{1}}
  \item{type}{override type detection when multiple types are non-zero, passed to v.out.ogr}
  \item{plugin}{default NULL if which case it will be set to the value set by \code{set.pluginOption}; NULL for auto-detection, may be set to FALSE to avoid or TRUE if the plugin is known to be available; if the plugin is used, no further arguments other than mapset are respected}
  \item{remove.duplicates}{In line and area vector objects, multiple geometrical features may be associated with a single cat number, leading to duplication of data rows; this argument attempts to combine the geometrical features so that they match a single data row}
  \item{ignore.stderr}{default the value set by
    \code{set.ignore.stderrOption}; NULL, taking the value set by \code{set.ignore.stderrOption}, can be set to TRUE to silence \code{system()} output to standard error; does not apply on Windows platforms}
  \item{with_prj}{default TRUE, write ESRI-style PRJ file for transfered data}
  \item{with_c}{default FALSE in GRASS 7; if FALSE, export features with category (labeled) only; if not default, all features are exported, including GRASS \dQuote{islands} which are probably spurious exterior rings filling holes.}
  \item{mapset}{if plugin is TRUE, the mapset of the file to be imported may be changed from the current mapset by passing a character string}
  \item{pointDropZ}{default FALSE, if TRUE, discard third coordinates for point geometries; third coordinates are alway discarded for line and polygon geometries}
  \item{driver}{default NULL, which will lead to the choice of the first driver found in a ordered preferred vector, currently \code{c("SQLite", "ESRI Shapefile")}; a valid OGR writable driver name to define the file format for intermediate files, one of \code{c("GML", "SQLite"), c("ESRI_Shapefile", "MapInfo_File")} is preferred as these construct the names of the intermediate files adequately}
  \item{min_area}{default 0.0001); Minimum size of area to be imported (square meters) Smaller areas and islands are ignored. Should be greater than snap^2}
  \item{snap}{default -1); Snapping threshold for boundaries (map units). '-1' for no snap}
  \item{SDF}{A Spatial*DataFrame to be moved to GRASS 7 as a vector object, for SpatialPointsDataFrame, SpatialLinesDataFrame, and SpatialPolygonsDataFrame objects, or an equivalent \code{"sf"} object}
  \item{v.in.ogr_flags}{Character vector containing additional optional flags and/or options for v.in.ogr, particularly "o" and "overwrite"}
  \item{ID}{A valid DB column name for unique identifiers (optional)}
  \item{remove}{default TRUE, remove copied vectors created in \code{vect2neigh}}
  \item{vname2}{If on a previous run, remove was FALSE, the name of the temporary vector may be given to circumvent its generation}
  \item{units}{default \dQuote{k}; see GRASS \code{v.to.db} manual page for alternatives}

}
\value{
   \code{readVECT} imports a GRASS 7 vector object into an Spatial*DataFrame or equivalent \code{"sf"} object with the type determined by the type of the GRASS 7 vector object. \code{readVECT} and \code{writeVECT} attempt to preserve longer column/field names despite using the \dQuote{ESRI Shapefile} format for transfer.

\code{vect2neigh} returns a data frame object with left and right neighbours and boundary lengths, also given class GRASSneigh and spatial.neighbour (as used in spdep). The incantation to retrieve the neighbours list is \code{sn2listw(vect2neigh())$neighbours}, and to retrieve the boundary lengths: \code{sn2listw(vect2neigh())$weights}. The GRASSneigh object has two other useful attributes: external is a vector giving the length of shared boundary between each polygon and the external area, and total giving each polygon's total boundary length.

}
\note{
Please note that the OGR drivers used may not handle missing data gracefully. From rgdal release 0.5-27, missing values are taken as unset OGR field values. If the OGR driver encodes them in this way, NAs will be moved across the interface correctly from R to GRASS, and from GRASS to R using the OGR GRASS vector plugin. Work is continuing to correct v.out.ogr so that it emits unset fields, which affects users with no OGR GRASS plugin for the present. Thanks to Dylan Beaudette for helping with missing data handling.

}
\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

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
if (run) {
  execGRASS("v.info", map="schools", layer="1")
}
if (run) {
  print(vInfo("schools"))
  schs <- readVECT("schools", plugin=NULL)
  print(summary(schs))
}
if (run) {
  schs1 <- readVECT("schools", plugin=FALSE)
  print(summary(schs1))
}
if (run) {
  writeVECT(schs, "newsch", v.in.ogr_flags=c("o", "overwrite"))
  execGRASS("v.info", map="newsch", layer="1")
}
if (run) {
  nschs <- readVECT("newsch")
  print(summary(nschs))
}
if (run) {
  print(all.equal(names(nschs), as.character(vColumns("newsch")[,2])))
}
if (run) {
  names(nschs) <- paste("ABCDEFGHIJKLMNO", names(nschs), sep="")
  writeVECT(nschs, "newsch1", v.in.ogr_flags=c("o", "overwrite"))
}
if (run) {
  print(all.equal(names(nschs), as.character(vColumns("newsch1")[-1,2])))
}
if (run) {
  nschs1 <- readVECT("newsch1")
  print(all.equal(names(nschs), names(nschs1)[-1]))
}
if (run) {
  print(summary(nschs1))
}
if (run) {
  schs <- readVECT("schools", driver="ESRI Shapefile")
  names(schs) <- paste("ABCDEFGHIJKLMNO", names(schs), sep="")
  writeVECT(schs, "newsch", v.in.ogr_flags=c("o", "overwrite"),
    driver="ESRI Shapefile")
  print(all.equal(names(schs), as.character(vColumns("newsch")[-1,2])))
}
if (run) {
  nschs <- readVECT("newsch", driver="ESRI Shapefile")
  all.equal(names(schs), names(nschs)[-1])
}
if (run) {
  print(vInfo("roadsmajor"))
}
if (run) {
  roads <- readVECT("roadsmajor")
  print(summary(roads))
}
if (run) {
  cen_neig <- vect2neigh("census")
  str(cen_neig)
}
use_sf()
if (run) {
  print(vInfo("schools"))
  schs <- readVECT("schools", plugin=NULL)
  print(summary(schs))
}
if (run) {
  schs1 <- readVECT("schools", plugin=FALSE)
  print(summary(schs1))
}
if (run) {
  writeVECT(schs, "newsch", v.in.ogr_flags=c("o", "overwrite"))
  execGRASS("v.info", map="newsch", layer="1")
}
if (run) {
  nschs <- readVECT("newsch")
  print(summary(nschs))
}
Sys.setenv("GRASS_VERBOSE"=GV)
set.ignore.stderrOption(ois)
use_sp()
}
\keyword{spatial}

