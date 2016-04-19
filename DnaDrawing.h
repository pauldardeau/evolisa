//
//  DnaDrawing.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Settings;
@class Tools;


@interface DnaDrawing : NSObject <NSCoding>
{
   NSUInteger _polygonCount;
   NSUInteger _brushStrokeCount;
   NSMutableArray* listPolygons;
   NSMutableArray* listBrushStrokes;
   BOOL isDirty;
   Settings* settings;
   Tools* tools;
   NSSize drawingSize;
}

@property (nonatomic,retain) NSMutableArray* listPolygons;
@property (nonatomic,retain) NSMutableArray* listBrushStrokes;
@property (nonatomic) BOOL isDirty;

- (id)initWithSize:(NSSize)theDrawingSize;
- (DnaDrawing*)initAsCloneFromDrawing:(DnaDrawing*)cloneFrom;

- (NSUInteger)getPolygonCount;
- (NSUInteger)getPointCount;
- (void)mutate;
- (void)movePolygon;
- (void)removePolygon;
- (void)addPolygon;

- (NSUInteger)getBrushStrokeCount;
- (void)addBrushStroke;
- (void)removeBrushStroke;
- (void)moveBrushStroke;

- (void)setSize:(NSSize)theDrawingSize;
- (float)width;
- (float)height;

- (NSSize)drawingSize;

@end
