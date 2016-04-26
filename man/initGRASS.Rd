\name{initGRASS}
\alias{initGRASS}
\alias{get.GIS_LOCK}
\alias{set.GIS_LOCK}
\alias{unset.GIS_LOCK}
\alias{unlink_.gislock}
\alias{remove_GISRC}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Initiate GRASS session}
\description{
  Run GRASS interface in an R session not started within GRASS. In general, most users will use \code{initGRASS} in throwaway locations, to use GRASS modules  on R objects without the need to define and populate a location. The function initializes environment variables used by GRASS, the .gisrc used by GRASS for further environment variables, and a temporary location. 

The locking functions are used internally, but are exposed for experienced R/GRASS scripters needing to use the GRASS module \dQuote{g.mapset} through \code{initGRASS} in an existing GRASS location. In particular, \dQuote{g.mapset} may leave a \code{.gislock} file in the current MAPSET, so it may be important to call \code{unlink_.gislock} to clean up before quitting the R session. \code{remove_GISRC} may be used to try to remove the file given in the \dQuote{GISRC} environment variable if created by \code{initGRASS} with argument \code{remove_GISRC=} TRUE.
}
\usage{
initGRASS(gisBase, home, SG, gisDbase, addon_base, location, mapset,
  override = FALSE, use_g.dirseps.exe = TRUE, pid, remove_GISRC=FALSE)
get.GIS_LOCK()
set.GIS_LOCK(pid)
unset.GIS_LOCK()
unlink_.gislock()
remove_GISRC()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{gisBase}{The directory path to GRASS binaries and libraries}
  \item{home}{The directory in which to create the .gisrc file; defaults to \code{$HOME} on Unix systems and to \code{USERPROFILE} on Windows systems; can usually be set to \code{tempdir()}}
  \item{SG}{An optional \code{SpatialGrid} object to define the \code{DEFAULT_WIND} of the temporary location}
  \item{gisDbase}{if missing, \code{tempdir()} will be used; GRASS GISDBASE directory for the working session}
  \item{addon_base}{if missing, assumed to be \dQuote{$HOME/.grass7/addons} on Unix-like platforms, on MS Windows \dQuote{\%APPDATA\%\\GRASS7\\addons}, and checked for existence}
  \item{location}{if missing, \code{basename(tempfile())} will be used; GRASS location directory for the working session}
  \item{mapset}{if missing, \code{basename(tempfile())} will be used; GRASS mapset directory for the working session}
  \item{override}{default FALSE, set to TRUE if accidental trashing of GRASS .gisrc files and locations is not a problem}
  \item{use_g.dirseps.exe}{default TRUE; when TRUE appears to work for WinGRASS Native binaries, when FALSE for QGIS GRASS binaries; ignored on other platforms.}
  \item{pid}{default \code{as.integer(round(runif(1, 1, 1000)))}, integer used to identify GIS_LOCK; the value here is arbitrary, but probably should be set correctly}
  \item{remove_GISRC}{default FALSE; if TRUE, attempt to unlink the temporary file named in the \dQuote{GISRC} environment variable when the R session terminates or when this package is unloaded}
}
\details{
  The function establishes an out-of-GRASS working environment providing GRASS commands with the environment variable support required, and may also provide a temporary location for use until the end of the running R session if the \code{home} argument is set to \code{tempdir()}, and the \code{gisDbase} argument is not given. Running \code{gmeta6} shows where the location is, should it be desired to archive it before leaving R.
}
\value{
  The function runs \code{gmeta6} before returning the current values of the running GRASS session that it provides.
}
\note{If any package command fails with a UTF-8 error from the XML package, try using \code{setXMLencoding} to work around the problem that GRASS modules declare --interface-description output as UTF-8 without ensuring that it is (French is of 6.4.0 RC5 latin1).}

\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no}}

\seealso{\code{\link{gmeta}}}
\examples{
\dontrun{
initGRASS("/usr/bin/grass-7.0.0", home=tempdir())
initGRASS("C:/GRASS", home=tempdir())
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{spatial}

