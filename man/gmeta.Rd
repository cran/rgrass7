% Copyright (C) 2005 Roger S. Bivand
%
\name{gmeta}
\alias{gmeta}
\alias{getLocationProj}
\alias{gmeta2grd}
\alias{print.gmeta}
\alias{get.ignore.stderrOption}
\alias{get.stop_on_no_flags_parasOption}
\alias{get.useGDALOption}
\alias{get.pluginOption}
\alias{get.echoCmdOption}
\alias{get.useInternOption}
\alias{get.legacyExecOption}
\alias{get.defaultFlagsOption}
\alias{get.suppressEchoCmdInFuncOption}
\alias{set.ignore.stderrOption}
\alias{set.stop_on_no_flags_parasOption}
\alias{set.useGDALOption}
\alias{set.pluginOption}
\alias{set.echoCmdOption}
\alias{set.useInternOption}
\alias{set.legacyExecOption}
\alias{set.defaultFlagsOption}
\alias{set.suppressEchoCmdInFuncOption}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Reads GRASS metadata from the current LOCATION}
\description{
  GRASS LOCATION metadata are read into a list in R; helper function getLocationProj returns an spproj-compliant PROJ.4 string of projection information. The helper function \code{gmeta2grd} creates a GridTopology object from the current GRASS mapset region definitions.
}
\usage{
gmeta(ignore.stderr = FALSE)
getLocationProj(ignore.stderr = FALSE)
gmeta2grd(ignore.stderr = FALSE)
\method{print}{gmeta}(x, ...)
get.ignore.stderrOption()
get.stop_on_no_flags_parasOption()
get.useGDALOption()
get.pluginOption()
get.echoCmdOption()
get.useInternOption()
get.legacyExecOption()
get.defaultFlagsOption()
get.suppressEchoCmdInFuncOption()
set.ignore.stderrOption(value)
set.stop_on_no_flags_parasOption(value)
set.useGDALOption(value)
set.pluginOption(value)
set.echoCmdOption(value)
set.useInternOption(value)
set.legacyExecOption(value)
set.defaultFlagsOption(value)
set.suppressEchoCmdInFuncOption(value)
}
\arguments{
  \item{ignore.stderr}{default FALSE, can be set to TRUE to silence \code{system()} output to standard error; does not apply on Windows platforms}
  \item{x}{S3 object returned by gmeta}
  \item{...}{arguments passed through print method}
  \item{value}{logical value for setting options on \code{ignore.stderr} set by default on package load to FALSE, \code{stop_on_no_flags_paras} set by default on package load to TRUE, \code{useGDAL} set by default on package load to TRUE, \code{plugin} set by default on package load to NULL, \code{echoCmd} set by default on package load to FALSE. \code{useIntern} sets the \code{intern} argument globally; \code{legacyExec} sets the \code{legacyExec} option globally, but is initialized to FALSE on unix systems (all but Windows) and TRUE on Windows; \code{defaultFlags} is initialized to NULL, but may be a character vector with values from \code{c("quiet", "verbose")} \code{suppressEchoCmdInFunc} default TRUE suppresses the effect of \code{echoCmd} within package functions, may be set FALSE for debugging.}
}
%- maybe also 'usage' for other objects documented here.

\value{
  Returns list of g.gisenv, g.region -g3, and g.proj values
}

\author{Roger S. Bivand, e-mail: \email{Roger.Bivand@nhh.no.}}

\examples{
if (nchar(Sys.getenv("GISRC")) > 0 &&
  read.dcf(Sys.getenv("GISRC"))[1,"LOCATION_NAME"] == "nc_basic_spm_grass7") {
  G <- gmeta()
  print(G)
  CRS(getLocationProj())
  grd <- gmeta2grd()
  print(grd)
  ncells <- prod(slot(grd, "cells.dim"))
  df <- data.frame(k=rep(1, ncells))
  mask_SG <- SpatialGridDataFrame(grd, data=df)
  print(summary(mask_SG))
}
}
\keyword{spatial}

