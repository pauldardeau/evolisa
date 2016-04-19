//
//  DrawingCanvas.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#import "DrawingCanvas.h"
#import "Tools.h"
#import "EvoLisaWindowController.h"

#import "DnaBrush.h"
#import "DnaDrawing.h"
#import "DnaPoint.h"
#import "DnaPolygon.h"
#import "DnaBrushStroke.h"


@implementation DrawingCanvas

@synthesize windowController;
@synthesize drawing;

//******************************************************************************

- (id)initWithFrame:(NSRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      frameRect = frame;
      tools = [[Tools instance] retain];
      DnaDrawing* aDrawing = [[DnaDrawing alloc] initWithSize:frame.size];
      self.drawing = aDrawing;
      [aDrawing release];
   }

   return self;
}

//******************************************************************************

- (void)dealloc {
   [tools release];
   self.windowController = nil;
   self.drawing = nil;
   [super dealloc];
}

//******************************************************************************

- (void)setFrame:(NSRect)frame {
   [super setFrame:frame];
   frameRect = frame;
   [drawing setSize:frame.size];
   [self setNeedsDisplay:YES];
}

//******************************************************************************

- (void)redraw {
   [self drawRect:[self bounds]];
}

//******************************************************************************

- (void)drawRect:(NSRect)dirtyRect {
   [[NSColor blackColor] set];
   NSRectFill([self bounds]);
   
   for (DnaPolygon* polygon in drawing.listPolygons) {
      [polygon.brush.brushColor set];
      
      NSBezierPath* path = [NSBezierPath bezierPath];
      DnaPoint* firstPoint = nil;
       
      for (DnaPoint* point in polygon.listPoints) {
          if (nil == firstPoint) {
              [path moveToPoint:point.point];
              firstPoint = point;
          } else {
              [path lineToPoint:point.point];
          }
      }
       
       [path lineToPoint:firstPoint.point];
       [path closePath];
       [path fill];
   }
    
    for (DnaBrushStroke* brushStroke in drawing.listBrushStrokes) {
        [brushStroke.brush.brushColor setStroke];
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path setLineWidth:brushStroke.brushWidth];
        [path moveToPoint:brushStroke.startingPoint.point];
        [path lineToPoint:brushStroke.endingPoint];
        [path closePath];
        [path stroke];
    }

   [windowController notifyOnDrawingCanvasDrawn];
}

//******************************************************************************

@end
