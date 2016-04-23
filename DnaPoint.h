//
//  DnaPoint.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DnaDrawing;
@class Settings;
@class Tools;


@interface DnaPoint : NSObject <NSCoding>
{
    NSPoint point;
    Settings* settings;
    Tools* tools;
    NSSize drawingSize;
}

@property (nonatomic) NSPoint point;

- (id)initWithSize:(NSSize)theDrawingSize;

- (DnaPoint*)initAsCloneFromPoint:(DnaPoint*)clone;
- (void)mutate:(DnaDrawing*)drawing;

- (void)setSize:(NSSize)drawingSize;

- (NSDictionary*)toDictionary;
+ (DnaPoint*)fromDictionary:(NSDictionary*)dict;

- (BOOL)isEqualToPoint:(DnaPoint*)other;

@end
