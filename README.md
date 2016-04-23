evolisa
=======

This project is an Objective-C variant of the original 'evolisa' done by
Roger Alsing in 2008:

https://rogeralsing.com/2008/12/07/genetic-programming-evolution-of-mona-lisa/

The results so far aren't anywhere near as good as his, but it's fun to experiment.

License
-------
BSD

Memory Management
-----------------
This project was initially coded before ARC was available. I'm not aware of any memory leaks.

Graphics
--------
*  **Cocoa** - implemented with **NSBezierPath** in **DrawingCanvas** (NSView subclass)
*  **OpenGL** - implemented using OpenGL triangles in **GLDrawingCanvas** (NSOpenGLView subclass)

The OpenGL drawing is significantly faster than the Cocoa drawing.

Serialization
-------------
Uses JSON by default. Still contains **very** hacky (and broken) original ASCII file serialization (need to fix or remove).

Optimizations
-------------
*  **Altivec** - first started hacking on this back when I had PowerPC chips still
laying around and left them there.
*  **GCD** - see dispatch_apply in gcdCompareImages:
*  **SSE** - currently don't have any form of SSE SIMD instructions, but they could be helpful
