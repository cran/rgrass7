# version 0.2-7 (development)

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
