//
//  DnaPolygon.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@class DnaBrush;
@class DnaDrawing;
@class Settings;
@class Tools;


@interface DnaPolygon : NSObject <NSCoding>
{
    NSMutableArray* listPoints;
    DnaBrush* brush;
    Settings* settings;
    Tools* tools;
}

@property (nonatomic,retain) NSMutableArray* listPoints;
@property (nonatomic,retain) DnaBrush* brush;

- (id)initWithSize:(NSSize)theDrawingSize;
- (DnaPolygon*)initAsCloneFromPolygon:(DnaPolygon*)cloneFrom;

- (NSUInteger)getPointCount;
- (void)mutate:(DnaDrawing*)drawing;

- (void)setSize:(NSSize)drawingSize;


@end
