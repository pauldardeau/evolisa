//
//  DnaPoint.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import "DnaPoint.h"
#import "DnaDrawing.h"
#import "Settings.h"
#import "Tools.h"

#define MAX_ZERO_TRIES  5


static NSString* KEY_POINT = @"point";
static NSString* KEY_SIZE = @"drawingSize";


@implementation DnaPoint

@synthesize point;

//******************************************************************************

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        settings = nil;
        tools = nil;
        //settings = [Settings instance];
        //tools = [Tools instance];
        point = [aDecoder decodePointForKey:KEY_POINT];
        drawingSize = [aDecoder decodeSizeForKey:KEY_SIZE];
    }
    
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodePoint:point forKey:KEY_POINT];
    [aCoder encodeSize:drawingSize forKey:KEY_SIZE];
}

//******************************************************************************

- (id)initWithSize:(NSSize)theDrawingSize {
    self = [super init];
    if (self) {
        settings = nil;
        tools = nil;
        //settings = [Settings instance];
        tools = [Tools instance];
        drawingSize = theDrawingSize;
      
        const int maxWidth = drawingSize.width;  // tools.maxWidth
        const int maxHeight = drawingSize.height;  // tools.maxHeight
      
        int x = 0;
        int y = 0;
        int tries = 0;
      
        while ((x == 0) && (y == 0) && (tries < MAX_ZERO_TRIES)) {
            x = [tools getRandomNumberWithMin:0 andMaximum:maxWidth];
            y = [tools getRandomNumberWithMin:0 andMaximum:maxHeight];
            ++tries;
        }
      
        if ((x == 0) && (y == 0)) {
            NSLog(@"x=0, y=0 DnaPoint.initWithSize");
        }
      
        //NSLog(@"maxWidth=%d, maxHeight=%d", maxWidth, maxHeight);
        //NSLog(@"point: x=%d, y=%d", x, y);
      
        self.point = NSMakePoint(x,y);
    }
   
    return self;
}

//******************************************************************************

- (DnaPoint*)initAsCloneFromPoint:(DnaPoint*)clone {
    self = [super init];
    if (self) {
        settings = nil;
        tools = nil;
        //settings = [Settings instance];
        //tools = [Tools instance];
        self.point = NSMakePoint(clone.point.x,clone.point.y);
        drawingSize = clone->drawingSize;
    }
   
    return self;
}

//******************************************************************************

- (void)mutate:(DnaDrawing*)drawing {
    const int maxWidth = drawingSize.width; // tools.maxWidth
    const int maxHeight = drawingSize.height; // tools.maxHeight
    int x;
    int y;
    int tries;
   
    if (!tools) {
        tools = [Tools instance];
    }
    
    if (!settings) {
        settings = [Settings instance];
    }
    
    if ([tools willMutate:settings.activeMovePointMaxMutationRate]) {
        x = 0;
        y = 0;
        tries = 0;
      
        while ((x == 0) && (y == 0) && (tries < MAX_ZERO_TRIES)) {
            x = [tools getRandomNumberWithMin:0 andMaximum:maxWidth];
            y = [tools getRandomNumberWithMin:0 andMaximum:maxHeight];
            ++tries;
        }
      
        if ((x > 0) && (y > 0)) {
            self.point = NSMakePoint(x, y);
            drawing.isDirty = YES;
        }
    }
   
    if ([tools willMutate:settings.activeMovePointMidMutationRate]) {
        x = 0;
        y = 0;
        tries = 0;
      
        while ((x == 0) && (y == 0) && (tries < MAX_ZERO_TRIES)) {
            int x_adj = [tools getRandomNumberWithMin:-settings.activeMovePointRangeMid
                                           andMaximum:settings.activeMovePointRangeMid];
            int y_adj = [tools getRandomNumberWithMin:-settings.activeMovePointRangeMid
                                           andMaximum:settings.activeMovePointRangeMid];
            x = MIN(MAX(0, point.x + x_adj), maxWidth);
            y = MIN(MAX(0, point.y + y_adj), maxHeight);
            ++tries;
        }

        if ((x > 0) && (y > 0)) {
            self.point = NSMakePoint(x, y);
            drawing.isDirty = YES;
        }
    }
   
    if ([tools willMutate:settings.activeMovePointMinMutationRate]) {
        x = 0;
        y = 0;
        tries = 0;
      
        while ((x == 0) && (y == 0) && (tries < MAX_ZERO_TRIES)) {
            int x_adj = [tools getRandomNumberWithMin:-settings.activeMovePointRangeMin
                                           andMaximum:settings.activeMovePointRangeMin];
            int y_adj = [tools getRandomNumberWithMin:-settings.activeMovePointRangeMin
                                           andMaximum:settings.activeMovePointRangeMin];
            x = MIN(MAX(0, point.x + x_adj), maxWidth);
            y = MIN(MAX(0, point.y + y_adj), maxHeight);
            ++tries;
        }
      
        if ((x > 0) && (y > 0)) {
            self.point = NSMakePoint(x, y);
            drawing.isDirty = YES;
        }
    }
}

//******************************************************************************

- (void)setSize:(NSSize)theDrawingSize {
    const double xPercent = point.x / drawingSize.width;
    const double yPercent = point.y / drawingSize.height;
    const int x = xPercent * theDrawingSize.width;
    const int y = yPercent * theDrawingSize.height;
   
    self.point = NSMakePoint(x, y);
    drawingSize = theDrawingSize;
}

//******************************************************************************

- (NSDictionary*)toDictionary {
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:NSStringFromPoint(point) forKey:KEY_POINT];
    [dict setValue:NSStringFromSize(drawingSize) forKey:KEY_SIZE];
    return dict;
}

//******************************************************************************

+ (DnaPoint*)fromDictionary:(NSDictionary *)dict {
    DnaPoint* dna_point = nil;
    
    NSString* s = [dict valueForKey:KEY_SIZE];
    if ([s length] > 0) {
        NSSize drawingSize = NSSizeFromString(s);
        s = [dict valueForKey:KEY_POINT];
        if ([s length] > 0 ) {
            dna_point = [[[DnaPoint alloc] initWithSize:drawingSize] autorelease];
            dna_point.point = NSPointFromString(s);
        }
    }
    
    return dna_point;
}

//******************************************************************************

- (BOOL)isEqualToPoint:(DnaPoint*)other {
    if ((self.point.x != other.point.x) ||
        (self.point.y != other.point.y)) {
        NSLog(@"NSPoint differs");
        return NO;
    }
    
    return YES;
}

//******************************************************************************

@end
