ClipperCocoa
============

An Objective-C wrapper for ClipperLib
(http://sourceforge.net/projects/polyclipping/). The developers page
with documentation, examples, and downloads can be found at http://www.angusj.com/delphi/clipper.php

This is known to work with version 6.1.3a.

For my own work with Cocos2D, I have also implemented routines to
create triangulations of polygons using the poly2tri library
(https://code.google.com/p/poly2tri/). If you #define HAVE_POLY2TRI
(most likely from the command line or project settings), then this
code will be compiled in. It expects to find poly2tri.h in the header
search paths.

* I am not distributing the Clipper or Poly2Tri sources with this, so
 you will have to get those on your own.
* I have tried to make the Path and Paths classes be similar to
  typical NSData containers (e.g. pathAtIndex and pointAtIndex
  routines). It isn't perfect, but makes it feel like you are working
  with real NSData types.
* There is some excessive allocation and de-allocation because Paths
  is a thin wrapper for ClipperLib::Paths and Path is a thin wrapper
  for ClipperLib::Path. So every call to [Paths pathForIndex:] allocates
  a new Path object. Not ideal, but I haven't seen enough slowdowns to
  make it more fancy.
