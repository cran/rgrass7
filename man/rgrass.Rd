\name{rgrass7-package}
\alias{rgrass7-package}
\alias{rgrass7}
\docType{package}
\title{
Interface between GRASS geographical information system and R
}
\description{
Interpreted interface between GRASS geographical
information system, version 7, and R, based on starting R from within the
GRASS environment, or on running R stand-alone and creating a throw-away GRASS environment from within R. The interface uses classes defined in the sp package
to hold spatial data.
}

\details{
Index:
\preformatted{
readRAST               read GRASS raster files
writeRAST              write GRASS raster files
readVECT               read GRASS vector object files
writeVECT              write GRASS vector object files
gmeta                  read GRASS metadata from the current LOCATION
getLocationProj         return a PROJ.4 string of projection information
gmeta2grd               create a GridTopology object from the GRASS region
vInfo                   return vector geometry information
vColumns                return vector database columns information
vDataCount              return count of vector database rows
vect2neigh              return area neighbours with shared boundary length
}
Note that the examples now use the smaller subset North Carolina location: \url{http://grass.osgeo.org/sampledata/north_carolina/nc_basic_spm_grass7.tar.gz}
}
\author{
Roger Bivand

Maintainer: Roger Bivand <Roger.Bivand@nhh.no>

}

\keyword{ package }
\keyword{ spatial }


\examples{
if (nchar(Sys.getenv("GISRC")) > 0 &&
  read.dcf(Sys.getenv("GISRC"))[1,"LOCATION_NAME"] == "nc_basic_spm_grass7") {
  require(rgdal)
  elevation <- readRAST("elevation", ignore.stderr=TRUE, plugin=FALSE)
  summary(elevation)
  grd <- gmeta2grd(ignore.stderr=TRUE)
  grd
  set.seed(1)
  pts <- spsample(elevation, 200, "random")
  smple <- SpatialPointsDataFrame(pts, data=over(pts, elevation))
  summary(smple)
  writeVECT(smple, "sp_dem", v.in.ogr_flags=c("overwrite", "o"), ignore.stderr=TRUE)
  bugsDF <- readVECT("schools", ignore.stderr=TRUE, mapset="PERMANENT")
  summary(bugsDF)
  vInfo("streams", ignore.stderr=TRUE)
  vColumns("streams", ignore.stderr=TRUE)
  vDataCount("streams", ignore.stderr=TRUE)
  streams <- readVECT("streams", type="line",
    remove.duplicates=FALSE, ignore.stderr=TRUE, plugin=FALSE)
  summary(streams)
}
}
