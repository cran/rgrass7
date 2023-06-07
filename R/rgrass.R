# Interpreted GRASS 7 interface functions
# Copyright (c) 2015-20 Roger S. Bivand
#

gmeta <- function(ignore.stderr = FALSE, g.proj_WKT=NULL) {
        .Deprecated(new="gmeta", package="rgrass", old="gmeta",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
        if (get.suppressEchoCmdInFuncOption()) {
            inEchoCmd <- get.echoCmdOption()
             tull <- set.echoCmdOption(FALSE)
        }
        tx <- execGRASS("g.region", flags=c("g", "3"), intern=TRUE,
            ignore.stderr=ignore.stderr)
	tx <- gsub("=", ":", tx)
	con <- textConnection(tx)
	res <- read.dcf(con)
	close(con)
	lres <- as.list(res)
	names(lres) <- colnames(res)
	lres$n <- as.double(lres$n)
	lres$s <- as.double(lres$s)
	lres$w <- as.double(lres$w)
	lres$e <- as.double(lres$e)
	lres$t <- as.double(lres$t)
	lres$b <- as.double(lres$b)
	lres$nsres <- as.double(lres$nsres)
	lres$nsres3 <- as.double(lres$nsres3)
	lres$ewres <- as.double(lres$ewres)
	lres$ewres3 <- as.double(lres$ewres3)
	lres$tbres <- as.double(lres$tbres)
	if (length(lres$rows) == 0) 
		lres$rows <- abs(as.integer((lres$n-lres$s)/lres$nsres))
	else lres$rows <- as.integer(lres$rows)
	if (length(lres$rows3) == 0) lres$rows3 <- lres$rows
	else lres$rows3 <- as.integer(lres$rows3)
	if (length(lres$cols) == 0) 
		lres$cols <- abs(as.integer((lres$e-lres$w)/lres$ewres))
	else lres$cols <- as.integer(lres$cols)
	if (length(lres$cols3) == 0) lres$cols3 <- lres$cols
	else lres$cols3 <- as.integer(lres$cols3)
	if (length(lres$depths) == 0) 
		lres$depths <- abs(as.integer((lres$t-lres$b)/lres$tbres))
	else lres$depths <- as.integer(lres$depths)
        lres$proj4 <- ""
        prj <- try(getLocationProj(g.proj_WKT=g.proj_WKT,
            ignore.stderr=ignore.stderr), silent=TRUE)
	if (!inherits(prj, "try-error")) lres$proj4 <- prj
        gisenv <- execGRASS("g.gisenv", flags="n", intern=TRUE,
            ignore.stderr=ignore.stderr)
	gisenv <- gsub("[';]", "", gisenv)
	gisenv <- strsplit(gisenv, "=")
	glist <- as.list(sapply(gisenv, function(x) x[2]))
	names(glist) <- sapply(gisenv, function(x) x[1])
	lres <- c(glist, lres)
	class(lres) <- "gmeta"
        if (get.suppressEchoCmdInFuncOption()) {
            tull <- set.echoCmdOption(inEchoCmd)
        }
	lres
}

print.gmeta <- function(x, ...) {
        .Deprecated(new="print.gmeta", package="rgrass", old="print.gmeta",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
    cat("gisdbase   ", x$GISDBASE, "\n")
    cat("location   ", x$LOCATION_NAME, "\n")
    cat("mapset     ", x$MAPSET, "\n")
    cat("rows       ", x$rows, "\n")
    cat("columns    ", x$cols, "\n")
    cat("north      ", x$n, "\n")
    cat("south      ", x$s, "\n")
    cat("west       ", x$w, "\n")
    cat("east       ", x$e, "\n")
    cat("nsres      ", x$nsres, "\n")
    cat("ewres      ", x$ewres, "\n")
    if (is.character(x$proj4[1]) && nzchar(x$proj4[1]))
        if (substr(x$proj4[1], 1, 1) == "+") 
            cat("projection ", paste(strwrap(x$proj4), collapse="\n"), "\n")
        else cat("projection:\n", x$proj4[1], "\n")
    invisible(x)
}

gmeta2grd <- function(ignore.stderr = FALSE) {
        .Deprecated(new="gmeta2grd", package="rgrass", old="gmeta2grd",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
	if (!requireNamespace("sp", quietly=TRUE))
		stop("sp required to creat a GridTopology object")
	G <- gmeta(ignore.stderr=ignore.stderr)
	cellcentre.offset <- c(G$w+(G$ewres/2), G$s+(G$nsres/2))
	cellsize <- c(G$ewres, G$nsres)
	cells.dim <- c(G$cols, G$rows)

	grd <- sp::GridTopology(cellcentre.offset=cellcentre.offset, 
		cellsize=cellsize, cells.dim=cells.dim)
	grd
}



getLocationProj <- function(ignore.stderr = FALSE, g.proj_WKT=NULL) {
# too strict assumption on g.proj Rohan Sadler 20050928
        .Deprecated(new="getLocationProj", package="rgrass", old="getLocationProj",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
    if (get.suppressEchoCmdInFuncOption()) {
        inEchoCmd <- get.echoCmdOption()
         tull <- set.echoCmdOption(FALSE)
    }
    gv <- .grassVersion()
    WKT2 <- gv >= "GRASS 7.6" 
    old_rgdal <- TRUE
    if (requireNamespace("rgdal", quietly = TRUE)) 
        old_rgdal <- packageVersion("rgdal") < "1.5.1"
    if (!is.null(g.proj_WKT)) {
        stopifnot(is.logical(g.proj_WKT))
        stopifnot(length(g.proj_WKT) == 1L)
        if (gv < "GRASS 7.6" || g.proj_WKT)
            warning("Only Proj4 string representation for GRASS < 7.6")
        if (!g.proj_WKT) WKT2 <- FALSE
    }
    if (WKT2 && !old_rgdal) {
        res <- paste(execGRASS("g.proj", flags=c("w"), intern=TRUE, 
            ignore.stderr=ignore.stderr), collapse="\n")
        if (substr(res, 1, 5) != "ERROR") {
            if (nchar(res) == 0L) {
                res <- paste(execGRASS("g.proj", flags=c("j"), intern=TRUE, 
                    ignore.stderr=ignore.stderr), collapse=" ")
            }
            return(res)
        }
    }
    projstr <- execGRASS("g.proj", flags=c("j", "f"), intern=TRUE, 
        ignore.stderr=ignore.stderr)
    if (length(grep("XY location", projstr)) > 0)
	projstr <- as.character(NA)
    if (length(grep("latlong", projstr)) > 0)
	projstr <- sub("latlong", "longlat", projstr)
    if (is.na(projstr)) uprojargs <- projstr
    	else uprojargs <- paste(unique(unlist(strsplit(projstr, " "))), 
		collapse=" ")
    if (length(grep("= ", uprojargs)) != 0) {
	warning(paste("No spaces permitted in PROJ4",
		"argument-value pairs:", uprojargs))
	uprojargs <- as.character(NA)
    }
    if (length(grep(" [:alnum:]", uprojargs)) != 0) {
	warning(paste("PROJ4 argument-value pairs",
		"must begin with +:", uprojargs))
	uprojargs <- as.character(NA)
    }
    if (get.suppressEchoCmdInFuncOption()) {
        tull <- set.echoCmdOption(inEchoCmd)
    }
    uprojargs
}

.g_findfile <- function(vname, type) {
    ms <- execGRASS("g.findfile", element=type, file=vname[1],
        intern=TRUE)
    tx <- gsub("=", ":", ms)
    con <- textConnection(tx)
    res <- read.dcf(con)
    close(con)
    lres <- as.list(res)
    names(lres) <- colnames(res)
    if (nchar(lres$name) == 0) 
        stop(paste(vname[1], "- file not found"))
    mapset <- gsub("'", "", lres$mapset)
    mapset    
}



.addexe <- function() {
    res <- ""
    SYS <- get("SYS", envir=.GRASS_CACHE)
    if (SYS == "WinNat") res =".exe"
    res
}


.grassVersion <- function(ignore.stderr=TRUE) {
    Gver <- try(execGRASS(
        "g.version",
        intern = TRUE, 
        ignore.stderr = ignore.stderr), silent=TRUE)
    if (inherits(Gver, "try-error"))
        Gver <- "sh: line 1: g.version: command not found"
    return(Gver)
}

.compatibleGRASSVersion <- function(gv=.grassVersion()) {
    compatible <- ( (gv >= "GRASS 7.0") & (gv < "GRASS 9.0") )
    if (gv == "sh: line 1: g.version: command not found") {
        compatible <- as.logical(NA)
        attr(compatible, "message") <- gv
        return(compatible)
    }
    if ( !compatible ){
        attr(compatible, "message") <- paste0(
            "\n### rgrass7 is not compatible with the GRASS GIS version '", gv, "'!",
            "\n### Please use the package appropriate to the GRASS GIS version:",
            "\n### GRASS GIS Version 5.x.y  --  GRASS",
            "\n### GRASS GIS Version 6.x.y  --  spgrass6",
            "\n### GRASS GIS Version 7.x.y  --  rgrass7",
            "\n### GRASS GIS Version 8.x.y  --  rgrass"
        )
    } else {
        attr(compatible, "message") <- paste0("rgrass7 is compatible with the GRASS GIS version '", gv, "' R is running in!")
    }
    return(compatible)
}

.get_R_interface <- function() get("R_interface", envir=.GRASS_CACHE)

use_sf <- function() {
        .Deprecated(old="use_sf",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
  if (requireNamespace("sf", quietly=TRUE) && 
    requireNamespace("stars", quietly=TRUE))
    assign("R_interface", "sf", envir=.GRASS_CACHE)
  else stop("sf or stars is not available. You need both packages installed.")
}

use_sp <- function() {
        .Deprecated(old="use_sp",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
  if (requireNamespace("sp", quietly=TRUE) && 
     requireNamespace("rgdal", quietly=TRUE))
     assign("R_interface", "sp", envir=.GRASS_CACHE)
  else stop("sp or rgdal is not available. You need both packages installed.")
}
