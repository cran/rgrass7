# Interpreted GRASS 7, 8 interface functions
# Copyright (c) 2022 Roger S. Bivand
#
read_VECT <- function(vname, layer, type=NULL, flags="overwrite",
    ignore.stderr = NULL) {
        .Deprecated(new="read_VECT", package="rgrass", old="read_VECT",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
     if (!(requireNamespace("terra", quietly=TRUE))) 
        stop("terra required for SpatVector output")
    if (is.null(ignore.stderr))
        ignore.stderr <- get.ignore.stderrOption()
    stopifnot(is.logical(ignore.stderr))
    if (missing(layer)) layer <- "1"
    layer <- as.character(layer)
    if (get.suppressEchoCmdInFuncOption()) {
        inEchoCmd <- set.echoCmdOption(FALSE)
    }
    vinfo <- vInfo(vname)
    types <- names(vinfo)[which(vinfo > 0)]
    if (is.null(type)) {
        if (length(grep("points", types)) > 0) type <- "point"
        if (length(grep("lines", types)) > 0) type <- "line"
        if (length(grep("areas", types)) > 0) type <- "area"
        if (is.null(type)) stop("Vector type not found")
    }
    tf <- tempfile(fileext=".gpkg")
    execGRASS("v.out.ogr", flags=flags, input=vname, type=type,
        layer=as.character(layer), output=tf, output_layer=vname,
        format="GPKG", ignore.stderr=ignore.stderr)
    res <- getMethod("vect", "character")(tf)
    if (!all(getMethod("is.valid", "SpatVector")(res))) 
        res <- getMethod("makeValid", "SpatVector")(res)
    if (get.suppressEchoCmdInFuncOption()) {
        tull <- set.echoCmdOption(inEchoCmd)
    }
    res
}

write_VECT <- function(x, vname, flags="overwrite", ignore.stderr = NULL) {

        .Deprecated(new="write_VECT", package="rgrass", old="write_VECT",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
     if (!(requireNamespace("terra", quietly=TRUE))) 
        stop("terra required for SpatVector input")
    if (is.null(ignore.stderr))
            ignore.stderr <- get.ignore.stderrOption()
    stopifnot(is.logical(ignore.stderr))
    if (get.suppressEchoCmdInFuncOption()) {
        inEchoCmd <- set.echoCmdOption(FALSE)
    }
    type <- NULL
    if (getMethod("geomtype", "SpatVector")(x) == "points") type <- "point"
    if (getMethod("geomtype", "SpatVector")(x) == "lines") type <- "line"
    if (getMethod("geomtype", "SpatVector")(x) == "polygons") type <- "boundary"
    if (is.null(type)) stop("Unknown data class")

    tf <- tempfile(fileext=".gpkg")
    getMethod("writeVector", c("SpatVector", "character"))(x, filename=tf,
        filetype="GPKG", overwrite=TRUE)
                    
    execGRASS("v.in.ogr", flags=flags, input=tf, output=vname, type=type,
        ignore.stderr=ignore.stderr)
    if (get.suppressEchoCmdInFuncOption()) 
        tull <- set.echoCmdOption(inEchoCmd)
}


