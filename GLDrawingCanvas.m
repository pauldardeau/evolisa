//
//  GLDrawingCanvas.m
//  EvoLisa
//
//  Created by Paul Dardeau on 2/24/12.
//  Copyright (c) 2012 Paul Dardeau. All rights reserved.
//

#import "GLDrawingCanvas.h"
#import "Tools.h"
#import "EvoLisaWindowController.h"

#import "DnaBrush.h"
#import "DnaDrawing.h"
#import "DnaPoint.h"
#import "DnaPolygon.h"


//******************************************************************************

static void drawAnObject(DnaDrawing* aDrawing) {
    if (aDrawing) {
        const float drawingWidth = [aDrawing width];
        const float drawingHeight = [aDrawing height];
        
        for (DnaPolygon* polygon in aDrawing.listPolygons) {
            NSColor* brushColor = polygon.brush.brushColor;
            CGFloat red = 0.0;
            CGFloat green = 0.0;
            CGFloat blue = 0.0;
            CGFloat alpha = 0.0;
            [brushColor getRed:&red green:&green blue:&blue alpha:&alpha];
            glColor4f(red, green, blue, alpha);

            NSArray* listPoints = polygon.listPoints;
            const NSUInteger numberPoints = [listPoints count];
        
            if (3 == numberPoints) {  // only triangles
                NSPoint point1 = [[listPoints objectAtIndex:0] point];
                NSPoint point2 = [[listPoints objectAtIndex:1] point];
                NSPoint point3 = [[listPoints objectAtIndex:2] point];
                
                CGFloat y1 = point1.y;
                CGFloat y2 = point2.y;
                CGFloat y3 = point3.y;
                
                float xPercent1 = point1.x / drawingWidth;
                float yPercent1 = y1 / drawingHeight;
                
                float xPercent2 = point2.x / drawingWidth;
                float yPercent2 = y2 / drawingHeight;
                
                float xPercent3 = point3.x / drawingWidth;
                float yPercent3 = y3 / drawingHeight;
                
                float zeroOneX1 = -1.0 + (xPercent1 * 2.0);
                float zeroOneY1 = -1.0 + (yPercent1 * 2.0);

                float zeroOneX2 = -1.0 + (xPercent2 * 2.0);
                float zeroOneY2 = -1.0 + (yPercent2 * 2.0);

                float zeroOneX3 = -1.0 + (xPercent3 * 2.0);
                float zeroOneY3 = -1.0 + (yPercent3 * 2.0);

                glBegin(GL_TRIANGLES);
                {
                    glVertex3f(zeroOneX1, zeroOneY1, 0.0);
                    glVertex3f(zeroOneX2, zeroOneY2, 0.0);
                    glVertex3f(zeroOneX3, zeroOneY3, 0.0);
                }
                glEnd();
            }
        }
    }
}

//******************************************************************************
//******************************************************************************

@implementation GLDrawingCanvas

@synthesize windowController;
@synthesize drawing;

//******************************************************************************

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        tools = [[Tools instance] retain];
        DnaDrawing* aDrawing = [[DnaDrawing alloc] initWithSize:frame.size];
        self.drawing = aDrawing;
        [aDrawing release];
    }
    
    return self;
}

//******************************************************************************

- (void)awakeFromNib {
    tools = [[Tools instance] retain];
    DnaDrawing* aDrawing = [[DnaDrawing alloc] initWithSize:[self frame].size];
    self.drawing = aDrawing;
    [aDrawing release];
}

//******************************************************************************

// update the projection matrix based on camera and view info
/*
- (void)updateProjection {
    GLdouble ratio, radians, wd2;
    GLdouble left, right, top, bottom, near, far;
    
    [[self openGLContext] makeCurrentContext];
    
    // set projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    near = -camera.viewPos.z - shapeSize * 0.5;
    if (near < 0.00001) {
        near = 0.00001;
    }
    
    far = -camera.viewPos.z + shapeSize * 0.5;
    if (far < 1.0) {
        far = 1.0;
    }
    
    radians = 0.0174532925 * camera.aperture / 2; // half aperture degrees to radians 
    wd2 = near * tan(radians);
    ratio = camera.viewWidth / (float) camera.viewHeight;
    if (ratio >= 1.0) {
        left  = -ratio * wd2;
        right = ratio * wd2;
        top = wd2;
        bottom = -wd2;  
    } else {
        left  = -wd2;
        right = wd2;
        top = wd2 / ratio;
        bottom = -wd2 / ratio;  
    }
    glFrustum(left, right, bottom, top, near, far);
}
 */

//******************************************************************************

// handles resizing of GL need context update and if the window dimensions change, a
// a window dimension update, reseting of viewport and an update of the projection matrix
/*
- (void)resizeGL {
    NSRect rectView = [self bounds];
    
    // ensure camera knows size changed
    if ((camera.viewHeight != rectView.size.height) ||
        (camera.viewWidth != rectView.size.width)) {

        camera.viewHeight = rectView.size.height;
        camera.viewWidth = rectView.size.width;
        
        glViewport(0, 0, camera.viewWidth, camera.viewHeight);
        [self updateProjection];  // update projection matrix
    }
}
 */

//******************************************************************************

- (void)drawRect:(NSRect)rect {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    drawAnObject(drawing);
    glFlush();
    [windowController notifyOnDrawingCanvasDrawn];
}

//******************************************************************************

- (NSBitmapImageRep*)bitmapImageRepFromView {
    NSRect visibleRect = [self visibleRect];
    int height = NSHeight(visibleRect);
    int width = NSWidth(visibleRect);
    
    NSBitmapImageRep* imageRep =
        [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                 pixelsWide:width
                                                 pixelsHigh:height
                                              bitsPerSample:8
                                            samplesPerPixel:4
                                                   hasAlpha:YES
                                                   isPlanar:NO
                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                bytesPerRow:0
                                               bitsPerPixel:0] autorelease];
    [[self openGLContext] makeCurrentContext];
    glReadPixels(0, 0, width, height,
                 GL_RGBA, GL_UNSIGNED_BYTE,
                 [imageRep bitmapData]);
    
    return imageRep;
}

//******************************************************************************

@end
