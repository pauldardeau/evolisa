//
//  DrawingCanvas.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Tools;
@class EvoLisaWindowController;
@class DnaDrawing;

@interface DrawingCanvas : NSView
{
   Tools* tools;
   EvoLisaWindowController* windowController;
   DnaDrawing* drawing;
   NSRect frameRect;
}

@property(nonatomic,retain) EvoLisaWindowController* windowController;
@property(nonatomic,retain) DnaDrawing* drawing;


- (void)redraw;

@end
