# version 0.2-12 (development)

* The R package `rgrass7` interfacing R and GRASS GIS will be removed from active availability on the Comprehensive R Archive Network (CRAN) during October 2023; it will be archived on CRAN. This is because the successor `rgrass` package has been available since mid-2022, and because the `rgdal` package on which `rgrass7` depends for exchanging files between R and GRASS GIS will also be archived in October 2023, as described in R-spatial evolution [project](https://www.r-consortium.org/all-projects/awarded-projects/2021-group-2#Preparing%20CRAN%20for%20the%20Retirement%20of%20rgdal,%20rgeos%20and%20maptools) [reports](https://r-spatial.org/r/2023/05/15/evolution4.html) (latest providing links to earlier). The main change between `rgrass7` and `rgrass` is that `terra` is used in place of `rgdal` for file transfer between R and GRASS. `rgrass7` functions have been marked as deprecated for almost a year now, and maintainers of packages using `rgrass7` have been notified. Please also refer to https://rsbivand.github.io/foss4g_2022/modernizing_220822.html for more details.

* #67 deprecating minor functions too and update README

# version 0.2-11 (2022-10-06)

* deprecate all functions - use **rgrass**, not this package

# version 0.2-10 (2022-05-02)

* resolve tidy HTML markup failure

# version 0.2-9 (2022-04-08)

* resolve issue #53 - logic problems in `initGRASS()` and `gmeta()` when no CRS given and when `SG=` is an **sp** object

# version 0.2-8 (2022-03-05)

* `readRAST()`, `writeRAST()`, `readVECT()` and `writeVECT()` marked as deprecated

* if a single `"SpatRaster"` not in memory is passed to write_RAST(), no temporary file is used, and the file name is passed directly to `r.in.gdal`

* **rgrass7** will keep dual old/new implementations, but old implementations will be deprecated at next version: `readRAST()`, `writeRAST()`, `readVECT()` and `writeVECT()`

* add re-implementations of `read_VECT()` and `write_VECT()` using **terra**

* add re-implementations of `read_RAST()` and `write_RAST()` using **terra** based on discussion in #42

* add **terra** to `Suggests:`

# version 0.2-7 (2022-01-28)

* change repo name and links

* use `g.remove` in `vect2neigh()` to avoid duplicate temporary files #36

* add `.github/CONTRIBUTING.md`

# version 0.2-6 (2021-10-01)

* #32 `proj.db` mismatch in Windows stand-alone GRASS 7.8.5 (9.8.6) and recent **rgdal** Windows CRAN binary (10.008), if WKT look-up fails, fallback to GRASS Proj4 string.

* #27 Fall-back to Proj4 if proj.db version for CRAN binary package differs from installed GRASS proj.db

* #24 Trap old **rgdal** in CRS lookup, see #15

# version 0.2-5 (2021-01-29)

* #23 (Mira Kattwinkel) fix regression impacting **openSTARS**.

# Version 0.2-4 (2021-01-07)

* #17-19 Suggestion and PR by Floris Vanderhaege to pass an unparsed string with a GRASS command, possible flags and parameters through execGRASS(). Implemented in stringexecGRASS().

* #20 to improve handling of GRASS commands with no flags or parameters, special-casing "g.gui", thanks to Floris Vanderhaege.

* #21-22 updating stale GRASS_PYTHON settings in initGRASS(); for GRASS >= 7.8, python3 is used, for earier GRASS python2.


# Version 0.2-3 (2020-12-07)

* #14 use unambiguous error messages for use_sf(), use_sp(), thanks to Floris Vanderhaege.

* #15 Change reported CRS to WKT for GRASS >= 7.6

* #16 Better error message for OSGeo4W users using initGRASS() outside the OSGeo4W console, thanks to Floris Vanderhaege.


# Version 0.2-1 (2019-08-06)

* Beginning transition from dependence on sp classes to letting the user choose sp or sf classes, pushing both choices back to Suggests.
