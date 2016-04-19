//
//  GLDrawingCanvas.h
//  EvoLisa
//
//  Created by Paul Dardeau on 2/24/12.
//  Copyright (c) 2012 Paul Dardeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>


typedef struct {
    GLdouble x,y,z;
} recVec;


@class Tools;
@class EvoLisaWindowController;
@class DnaDrawing;


@interface GLDrawingCanvas : NSOpenGLView
{
    Tools* tools;
    EvoLisaWindowController* windowController;
    DnaDrawing* drawing;
}

@property(nonatomic,retain) EvoLisaWindowController* windowController;
@property(nonatomic,retain) DnaDrawing* drawing;

- (NSBitmapImageRep*)bitmapImageRepFromView;

@end
