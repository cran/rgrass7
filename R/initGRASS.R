# Interpreted GRASS 7, 8 raster interface functions
# Copyright (c) 2008-22 Roger S. Bivand
#
# GIS_LOCK 110814 RSB, suggested by Brian Oney
get.GIS_LOCK <- function() {
    Sys.getenv("GIS_LOCK")
}

set.GIS_LOCK <- function(pid) {
    if (missing(pid)) pid <- round(runif(1, 1, 1000))
    pid <- as.integer(pid)
    stopifnot(!is.na(pid))
    Sys.setenv(GIS_LOCK=pid)
}

unset.GIS_LOCK <- function() {
    Sys.unsetenv("GIS_LOCK")
}

unlink_.gislock <- function() {
    gl <- paste(Sys.getenv("GISDBASE"), Sys.getenv("LOCATION_NAME"),
        Sys.getenv("MAPSET"), ".gislock", sep="/")
    if (file.exists(gl)) unlink(gl)
}

initGRASS <- function(gisBase, home, SG, gisDbase, addon_base, location,
    mapset, override=FALSE, use_g.dirseps.exe=TRUE, pid, remove_GISRC=FALSE,
    ignore.stderr=get.ignore.stderrOption()) {
        .Deprecated(new="initGRASS", package="rgrass", old="initGRASS",
            msg="Package rgrass7 transitioning to package rgrass for GRASS 7+.")
    if (nchar(Sys.getenv("GISRC")) > 0 && !override)
      stop("A GRASS location is already in use; to override, set override=TRUE")

    if (nchar(get.GIS_LOCK()) > 0) {
      if(!override)
        stop("A GIS_LOCK environment variable is present; to override, set override=TRUE")
      else unset.GIS_LOCK()
    }

    if (missing(pid)) pid <- round(runif(1, 1, 1000))
    pid <- as.integer(pid)
    stopifnot(!is.na(pid))
    stopifnot(is.logical(override))
    stopifnot(length(override) == 1)
    stopifnot(is.logical(use_g.dirseps.exe))
    stopifnot(length(use_g.dirseps.exe) == 1)
    stopifnot(is.logical(remove_GISRC))
    stopifnot(length(remove_GISRC) == 1)

    if (!file.exists(gisBase)) stop(paste(gisBase, "not found"))
    if (!file.info(gisBase)$isdir[1]) stop(gisBase, " is not a directory")
    bin_is_dir <- file.info(file.path(gisBase, "bin"))$isdir[1]
    if (is.na(bin_is_dir)) 
      stop(gisBase, " does not contain bin, the directory with GRASS programs")
    if (!bin_is_dir) stop(gisBase, "/bin is not a directory")
    scripts_is_dir <- file.info(file.path(gisBase, "scripts"))$isdir[1]
    if (is.na(scripts_is_dir)) 
      stop(gisBase, " does not contain scripts, the directory with GRASS scripts")
    if (!scripts_is_dir) stop(gisBase, "/scripts is not a directory")

    SYS <- get("SYS", envir=.GRASS_CACHE) 
    if (SYS == "WinNat") {
# grass63.bat
        Sys.setenv(GISBASE=gisBase)
        if (missing(home)) home <- Sys.getenv("USERPROFILE")
        Sys.setenv(HOME=home)
        if (missing(addon_base))
            addon_base <- paste(Sys.getenv("APPDATA"),
                "/GRASS7/addons", sep="")
        addon_res <- file.exists(addon_base, paste(addon_base, "/bin", sep=""))
        if (any(addon_res)) Sys.setenv("GRASS_ADDON_BASE"=addon_base)
        OSGEO4W_ROOT <- Sys.getenv("OSGEO4W_ROOT")
        if (nchar(OSGEO4W_ROOT) > 0) {
            Sys.setenv(GRASS_PROJSHARE=paste(OSGEO4W_ROOT,
                "\\share\\proj", sep=""))
        } else {
            unistring <- toupper(gisBase)
            unistring <- gsub("\\\\", "/", unistring)
            if (length(grep("OSGEO4W.*/APPS/GRASS", unistring)) > 0)
                stop("NOTE: If using OSGeo4W GRASS, start R in the OSGeo4W shell,\nsee help(initGRASS) for further details")
            Sys.setenv(GRASS_PROJSHARE=paste(Sys.getenv("GISBASE"),
                "\\share\\proj", sep=""))
        }
        Wpath <- Sys.getenv("PATH")
        if (length(grep(basename(Sys.getenv("GISBASE")), Wpath)) < 1) {
            Sys.setenv(PATH=paste(Sys.getenv("GISBASE"), "\\lib;", 
                Sys.getenv("PATH"), sep=""))
            Sys.setenv(PATH=paste(Sys.getenv("GISBASE"), "\\bin;", 
                Sys.getenv("PATH"), sep=""))
            Sys.setenv(PATH=paste(Sys.getenv("GISBASE"), "\\extrabin;",
                Sys.getenv("PATH"), sep=""))
            if (addon_res[2]) Sys.setenv(PATH=paste(Sys.getenv(
                "GRASS_ADDON_BASE"), "\\bin;", Sys.getenv("PATH"), sep=""))
# etc/Init.bat
#            GRASS_addons <- Sys.getenv("GRASS_ADDON_PATH")
#            if (GRASS_addons == "")
#                Sys.setenv(PATH=paste(Sys.getenv("WINGISBASE"), "\\bin;",
#                    Sys.getenv("WINGISBASE"), "\\lib;",
#                    Sys.getenv("PATH"), sep=""))
#            else 
#                Sys.setenv(PATH=paste(Sys.getenv("WINGISBASE"), "\\bin;",
#                    Sys.getenv("WINGISBASE"), "\\lib;",
#                    GRASS_addons, ";", Sys.getenv("PATH"), sep=""))
            ePyPATH <- Sys.getenv("PYTHONPATH")
            if ((length(grep(basename(Sys.getenv("GISBASE")), ePyPATH)) < 1) 
                || nchar(ePyPATH) == 0) {
                GrPyPATH <- paste(Sys.getenv("GISBASE"), "/etc/python",
                    sep="")
                if (nchar(ePyPATH) > 0)
                    Sys.setenv(PYTHONPATH=paste(GrPyPATH, ePyPATH, sep=";"))
                else Sys.setenv(PYTHONPATH=GrPyPATH)
            }
            if (nchar(OSGEO4W_ROOT) > 0) {
              Sys.setenv("PYTHONHOME"=paste(OSGEO4W_ROOT, "apps/Python37", sep="/"))
            } else {
              G_B_files <- list.files(Sys.getenv("GISBASE"))
              Python_dir <- G_B_files[grep("Python", G_B_files)]
              if (length(Python_dir) > 0) Sys.setenv("PYTHONHOME"=paste(Sys.getenv("GISBASE"), Python_dir[1], sep="/"))
            }
#            pyScripts <- basename(list.files(paste(Sys.getenv("GISBASE"),
#                "scripts", sep="/"), pattern="py$"))
#            names(pyScripts) <- sub("\\.py", "", pyScripts)
#            assign("pyScripts", pyScripts, envir=.GRASS_CACHE)
        }
        Sys.setenv(GISRC=paste(Sys.getenv("HOME"), "\\.grassrc7", sep=""))
        if (file.exists(Sys.getenv("GISRC")) && !override)
            stop("A GISRC file already exists; to override, set override=TRUE")
        fn_gisrc <- "junk"
        if (isTRUE(file.access(".", 2) == 0)) {
            Sys.setenv(GISRC=fn_gisrc)
        } else {
            warning("working directory not writable, using tempfile for GISRC")
            Sys.setenv(GISRC=paste0(tempfile(), "_", fn_gisrc))
        }
        cat("GISDBASE:", getwd(), "\n", file=Sys.getenv("GISRC"))
        cat("LOCATION_NAME: <UNKNOWN>", "\n", file=Sys.getenv("GISRC"),
            append=TRUE)
        cat("MAPSET: <UNKNOWN>", "\n", file=Sys.getenv("GISRC"),
            append=TRUE)
        gisrc <- ifelse (use_g.dirseps.exe, system(paste("g.dirseps.exe -g",
            shQuote(Sys.getenv("GISRC"))), intern=TRUE),
            Sys.getenv("GISRC"))
        assign("addEXE", .addexe(), envir=.GRASS_CACHE)
        Sys.setenv(GISRC=gisrc)
        if (!missing(gisDbase)) {
            if (!file.exists(gisDbase)) dir.create(gisDbase)
        } else {
            gisDbase <- tempdir()
        }
        gisDbase <- ifelse (use_g.dirseps.exe, system(paste("g.dirseps.exe -g",
            shQuote(gisDbase)), intern=TRUE), gisDbase)
    } else if (SYS == "unix") {
        OSGEO4W_ROOT <- ""
        Sys.setenv(GISBASE=gisBase)
        if (missing(home)) home <- Sys.getenv("HOME")
        if (missing(addon_base))
            addon_base <- paste(Sys.getenv("HOME"), "/.grass7/addons", sep="")
        addon_res <- file.exists(addon_base, paste(addon_base, "/bin", sep=""),
            paste(addon_base, "/scripts", sep=""))
        if (any(addon_res)) Sys.setenv("GRASS_ADDON_BASE"=addon_base)
        ePATH <- Sys.getenv("PATH")
        if (length(grep(basename(Sys.getenv("GISBASE")), ePATH)) < 1) {
          Sys.setenv(PATH=paste(Sys.getenv("GISBASE"), "/bin:",
          Sys.getenv("GISBASE"), "/scripts",
          ifelse(addon_res[2],
            paste(":", Sys.getenv("GRASS_ADDON_BASE"), "/bin", sep=""), ""),
          ifelse(addon_res[3],
            paste(":", Sys.getenv("GRASS_ADDON_BASE"), "/scripts", sep=""),
            ""), 
          ifelse(nchar(ePATH) == 0, "", ":"), ePATH, sep=""))
        }
        eLDPATH <- Sys.getenv("LD_LIBRARY_PATH")
        if (length(grep(basename(Sys.getenv("GISBASE")), eLDPATH)) < 1) {
            Sys.setenv(LD_LIBRARY_PATH=paste(Sys.getenv("GISBASE"), "/lib:",
            ifelse(nchar(eLDPATH) == 0, "", ":"), eLDPATH, sep=""))
        }
#FIXME Sys.info()["sysname"] == "Darwin"
        Sys.setenv(GISRC=paste(home, "/.grassrc7", sep=""))
#FIXME
        if (file.exists(Sys.getenv("GISRC")) && !override)
            stop("A GISRC file already exists; to override, set override=TRUE")
        ePyPATH <- Sys.getenv("PYTHONPATH")
        if (length(grep(basename(Sys.getenv("GISBASE")), ePyPATH)) < 1 
            || nchar(ePyPATH) == 0) {
            GrPyPATH <- paste(Sys.getenv("GISBASE"), "etc", "python", sep="/")
            if (nchar(ePyPATH) > 0)
                 Sys.setenv(PYTHONPATH=paste(GrPyPATH, ePyPATH, sep=":"))
            else Sys.setenv(PYTHONPATH=GrPyPATH)
        }
        if (!missing(gisDbase)) {
            if (!file.exists(gisDbase)) dir.create(gisDbase)
        } else {
            gisDbase <- tempdir()
        }
        cat("GISDBASE:", gisDbase, "\n", file=Sys.getenv("GISRC"))
        cat("LOCATION_NAME: <UNKNOWN>", "\n", file=Sys.getenv("GISRC"),
            append=TRUE)
        cat("MAPSET: <UNKNOWN>", "\n", file=Sys.getenv("GISRC"),
            append=TRUE)
    } else stop(paste("Platform variant", SYS, "not supported"))
    set.GIS_LOCK(pid)
    assign("INIT_USED", TRUE, envir=.GRASS_CACHE)
    assign("GIS_LOCK", pid, envir=.GRASS_CACHE)
    if (remove_GISRC) assign("remove_GISRC", remove_GISRC, envir=.GRASS_CACHE)
    system(paste(paste("g.gisenv", get("addEXE", envir=.GRASS_CACHE), sep=""),
        shQuote(paste("set=GISDBASE=", gisDbase))))
    if (missing(location)) location <- basename(tempfile())
    loc_path <- paste(gisDbase, location, sep="/")
    if (!file.exists(loc_path)) dir.create(loc_path)
    if (!file.exists(paste(loc_path, "PERMANENT", sep="/")))
        dir.create(paste(loc_path, "PERMANENT", sep="/"))
    if (missing(mapset)) mapset <- basename(tempfile())
    if (!file.exists(paste(loc_path, mapset, sep="/")))
        dir.create(paste(loc_path, mapset, sep="/"))
    system(paste(paste("g.gisenv", get("addEXE", envir=.GRASS_CACHE), sep=""),
        shQuote(paste("set=GISDBASE", gisDbase, sep="="))))
    system(paste(paste("g.gisenv", get("addEXE", envir=.GRASS_CACHE), sep=""),
        shQuote(paste("set=LOCATION_NAME", location, sep="="))))
    system(paste(paste("g.gisenv", get("addEXE", envir=.GRASS_CACHE), sep=""),
        shQuote(paste("set=MAPSET", mapset, sep="="))))
    system(paste(paste("g.gisenv", get("addEXE", envir=.GRASS_CACHE), sep=""),
        shQuote("set=GRASS_GUI=text")))
    Sys.setenv(GISBASE=gisBase)
    Sys.setenv(GISDBASE=gisDbase)
    Sys.setenv(LOCATION_NAME=location)
    Sys.setenv(MAPSET=mapset)
    gv <- system(paste("g.version", get("addEXE", envir=.GRASS_CACHE),
                       sep=""),  intern=TRUE)
    

    comp <- .compatibleGRASSVersion(gv)
    if ( !comp ){
        stop( attr(comp, "message") )
    }
    grass_python <- Sys.getenv("GRASS_PYTHON")
    if (grass_python == "") {
      if (nchar(OSGEO4W_ROOT) > 0) {
        if (file.exists(paste(OSGEO4W_ROOT, "bin/python3.exe", sep="/"))) {
          Sys.setenv("GRASS_PYTHON"=paste(OSGEO4W_ROOT, "bin/python3.exe", sep="/"))
        } else {
          Sys.setenv("GRASS_PYTHON"=paste(OSGEO4W_ROOT, "bin/python.exe", sep="/"))
        }
      } else {
        if (strsplit(system(paste("g.version", get("addEXE", envir=.GRASS_CACHE), " -g ", sep=""), intern=TRUE)[1], "=")[[1]][2] > "7.6.1")
            Sys.setenv("GRASS_PYTHON"=paste("python3", get("addEXE",
                envir=.GRASS_CACHE), sep=""))
        else
            Sys.setenv("GRASS_PYTHON"=paste("python", get("addEXE",
                envir=.GRASS_CACHE), sep=""))
      }
    }
    
    assign("GV", gv, envir=.GRASS_CACHE)
    pfile <- paste(loc_path, "PERMANENT", "DEFAULT_WIND", sep="/")
    mSG <- FALSE
    if (!file.exists(pfile)) {
        lonlat <- FALSE
        mSG <- !missing(SG)
        if (mSG) {
            if (inherits(SG, "SpatialGrid")) {
                if (!requireNamespace("sp", quietly=TRUE))
                    stop("The sp package is required for the SG argument")
                bb <- sp::bbox(SG)
                gt <- sp::gridparameters(SG)
                wkt_SG <- sp::wkt(SG)
                lonlatSG <- !sp::is.projected(SG)
            } else if (inherits(SG, "SpatRaster")) {
                if (!requireNamespace("terra", quietly=TRUE))
                    stop("The terra package is required for the SG argument")
                bb <- getMethod("ext", "SpatRaster")(SG)@ptr$vector
                bb <- matrix(bb, 2, 2, byrow=TRUE)
                colnames(bb) <- c("min", "max")
                cs <- getMethod("res", "SpatRaster")(SG)
                co <- bb[,1]+(cs/2)
                cd <- c(getMethod("ncol", "SpatRaster")(SG), 
                    getMethod("nrow", "SpatRaster")(SG))
                gt <- data.frame(cellcentre.offset=co, cellsize=cs,
                    cells.dim=cd)
                wkt_SG <- getMethod("crs", "SpatRaster")(SG)
                lonlatSG <- getMethod("is.lonlat", "SpatRaster")(SG)
            } else {
                stop ("SG must be a terra or SpatialGrid object")
            }
            lonlat <- !is.na(lonlatSG) && lonlatSG
        }
        cat("proj:       ", ifelse(lonlat, 3, 99), "\n", file=pfile)
        cat("zone:       0\n", file=pfile, append=TRUE)
        cat("north:      ", ifelse(mSG, bb[2, "max"], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("south:      ", ifelse(mSG, bb[2, "min"], 0), "\n",
            sep="", file=pfile, append=TRUE)
        cat("east:       ", ifelse(mSG, bb[1, "max"], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("west:       ", ifelse(mSG, bb[1, "min"], 0), "\n",
            sep="", file=pfile, append=TRUE)
        cat("cols:       ", ifelse(mSG, gt$cells.dim[1], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("rows:       ", ifelse(mSG, gt$cells.dim[2], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("e-w resol:  ", ifelse(mSG, gt$cellsize[1], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("n-s resol:  ", ifelse(mSG, gt$cellsize[2], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("top:        1\n", sep="", file=pfile, append=TRUE)
        cat("bottom:     0\n", sep="", file=pfile, append=TRUE)
        cat("cols3:      ", ifelse(mSG, gt$cells.dim[1], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("rows3:      ", ifelse(mSG, gt$cells.dim[2], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("depths:     1\n", sep="", file=pfile, append=TRUE)
        cat("e-w resol3: ", ifelse(mSG, gt$cellsize[1], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("n-s resol3: ", ifelse(mSG, gt$cellsize[2], 1), "\n",
            sep="", file=pfile, append=TRUE)
        cat("t-b resol:  1\n", sep="", file=pfile, append=TRUE)
    }
    
    tfile <- paste(loc_path, "PERMANENT", "WIND", sep="/")
    if (!file.exists(tfile)) file.copy(pfile, tfile, overwrite=TRUE)
    tfile <- paste(loc_path, mapset, "WIND", sep="/")
    if (!file.exists(tfile)) file.copy(pfile, tfile, overwrite=TRUE)
    execGRASS("g.region", save="input", flags="overwrite",
        ignore.stderr=ignore.stderr)
    if (mSG) {
        if (nzchar(wkt_SG)) {
            tf <- tempfile()
            writeLines(wkt_SG, con=tf)
            MS <- execGRASS("g.mapset", flags="p", intern=TRUE,
                ignore.stderr=ignore.stderr)
	    if (MS != "PERMANENT") 
                execGRASS("g.mapset", mapset="PERMANENT", flags="quiet",
                    ignore.stderr=ignore.stderr)
            tull <- execGRASS("g.proj", flags="c", wkt=tf,
                ignore.stderr=ignore.stderr, intern=TRUE)
            execGRASS("g.region", flags="s", region=paste0("input@", mapset),
                ignore.stderr=ignore.stderr)
            execGRASS("g.region", flags="d", ignore.stderr=ignore.stderr)
	    if (MS != "PERMANENT") 
                execGRASS("g.mapset", mapset=mapset, flags="quiet",
                    ignore.stderr=ignore.stderr)
        }
    }
    gmeta(ignore.stderr=ignore.stderr)
}

remove_GISRC <- function() {
    if (get("INIT_USED", envir=.GRASS_CACHE) && 
        get("remove_GISRC", envir=.GRASS_CACHE)) {
        gisrc <- Sys.getenv("GISRC")
        if (file.exists(gisrc)) unlink(gisrc)
        Sys.unsetenv("GISRC")
    }
}
