# version 0.2-5 (development)

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
