//
//  DnaBrushStroke.m
//  EvoLisa
//
//  Created by Paul Dardeau on 3/30/13.
//
//

#import <math.h>

#import "DnaBrushStroke.h"
#import "Tools.h"
#import "Settings.h"
#import "DnaBrush.h"
#import "DnaDrawing.h"
#import "DnaPoint.h"

#define PI 3.1415

#define DEGREES_TO_RADIANS(degrees)degrees*PI/180.0


static const int MIN_BRUSH_WIDTH = 2;
static const int MAX_BRUSH_WIDTH = 15;
static const int MIN_STROKE_LENGTH = 5;
static const int MAX_STROKE_LENGTH = 30;


@implementation DnaBrushStroke

@synthesize startingPoint;
@synthesize endingPoint;
@synthesize angleDirection;
@synthesize brushWidth;
@synthesize strokeLength;
@synthesize brush=_brush;

//******************************************************************************

- (id)init {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
    }
    
    return self;
}

//******************************************************************************

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        self.startingPoint = [aDecoder decodeObjectForKey:@"startingPoint"];
        self.angleDirection = [aDecoder decodeIntForKey:@"angleDirection"];
        self.brushWidth = [aDecoder decodeIntForKey:@"brushWidth"];
        self.strokeLength = [aDecoder decodeIntForKey:@"strokeLength"];
        self.brush = [aDecoder decodeObjectForKey:@"brush"];
        
        [self calculateEndingPoint];
    }
    
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.startingPoint forKey:@"startingPoint"];
    [aCoder encodeInt:angleDirection forKey:@"angleDirection"];
    [aCoder encodeInt:brushWidth forKey:@"brushWidth"];
    [aCoder encodeInt:strokeLength forKey:@"strokeLength"];
    [aCoder encodeObject:self.brush forKey:@"brush"];
}

//******************************************************************************

- (id)initWithSize:(NSSize)theDrawingSize {
    self = [super init];
    
    if (self) {
        DnaBrush* aBrush = [[DnaBrush alloc] init];
        self.brush = aBrush;
        [aBrush release];
        
        settings = [Settings instance];
        tools = [Tools instance];

        DnaPoint* aPoint = [[DnaPoint alloc] initWithSize:theDrawingSize];
        self.startingPoint = aPoint;
        [aPoint release];
        
        self.angleDirection = [tools getRandomNumberWithMin:0 andMaximum:359];
        self.brushWidth = [tools getRandomNumberWithMin:MIN_BRUSH_WIDTH
                                             andMaximum:MAX_BRUSH_WIDTH];
        self.strokeLength = [tools getRandomNumberWithMin:MIN_STROKE_LENGTH
                                               andMaximum:MAX_STROKE_LENGTH];
        
        [self calculateEndingPoint];
    }
    
    return self;
}

//******************************************************************************

- (DnaBrushStroke*)initAsCloneFromBrushStroke:(DnaBrushStroke*)cloneFrom {
    self = [super init];
    
    if (self) {
        DnaBrush* cloneBrush = cloneFrom.brush;
        DnaBrush* newBrush =
           [[DnaBrush alloc] initAsCloneFromBrush:cloneBrush];
        self.brush = newBrush;
        [newBrush release];
        
        settings = [Settings instance];
        tools = [Tools instance];
        
        DnaPoint* newPoint =
           [[DnaPoint alloc] initAsCloneFromPoint:cloneFrom.startingPoint];
        self.startingPoint = newPoint;
        [newPoint release];
        
        angleDirection = cloneFrom.angleDirection;
        brushWidth = cloneFrom.brushWidth;
        strokeLength = cloneFrom.strokeLength;
        
        self.endingPoint = cloneFrom.endingPoint;
    }
    
    return self;
}

//******************************************************************************

- (void)dealloc {
    self.startingPoint = nil;
    [_brush release];
    [super dealloc];
}

//******************************************************************************

- (void)translate:(DnaDrawing*)drawing {
    DnaPoint* aPoint = [[DnaPoint alloc] initWithSize:[drawing drawingSize]];
    self.startingPoint = aPoint;
    [aPoint release];
}

//******************************************************************************

- (void)rotate:(DnaDrawing*)drawing {
    self.angleDirection = [tools getRandomNumberWithMin:0 andMaximum:359];
}

//******************************************************************************

- (void)alterBrushWidth:(DnaDrawing*)drawing {
    self.brushWidth = [tools getRandomNumberWithMin:MIN_BRUSH_WIDTH
                                         andMaximum:MAX_BRUSH_WIDTH];
}

//******************************************************************************

- (void)alterStokeLength:(DnaDrawing*)drawing {
    self.strokeLength = [tools getRandomNumberWithMin:MIN_STROKE_LENGTH
                                           andMaximum:MAX_STROKE_LENGTH];
}

//******************************************************************************

- (void)mutate:(DnaDrawing*)drawing {
    BOOL endPointCalcNeeded = NO;
    
    if ([tools willMutate:settings.activeTranslationRate]) {
        [self translate:drawing];
        endPointCalcNeeded = YES;
    }
    
    if ([tools willMutate:settings.activeColorChangeRate]) {
        [self.brush mutate:drawing];
    }
    
    if ([tools willMutate:settings.activeRotationRate]) {
        [self rotate:drawing];
        endPointCalcNeeded = YES;
    }
    
    if (endPointCalcNeeded) {
        [self calculateEndingPoint];
    }
}

//******************************************************************************

- (void)calculateEndingPoint {
    double angle = angleDirection;
    
    if (angle >= 270.0) {
        // 4th quadrant (270 - 359)
        angle -= 270.0;
        double radians = DEGREES_TO_RADIANS(angle);
        double sinValue = sin(radians);
        double cosValue = cos(radians);
        double x = cosValue * strokeLength;
        double y = sinValue * strokeLength;
        self.endingPoint = NSMakePoint(startingPoint.point.x - x,
                                       startingPoint.point.y - y);
    } else if (angle >= 180.0) {
        // 3rd quadrant (180 - 269)
        angle -= 180.0;
        double radians = DEGREES_TO_RADIANS(angle);
        double sinValue = sin(radians);
        double cosValue = cos(radians);
        double x = sinValue * strokeLength;
        double y = cosValue * strokeLength;
        self.endingPoint = NSMakePoint(startingPoint.point.x - x,
                                       startingPoint.point.y + y);
    } else if (angle >= 90.0) {
        // 2nd quadrant (90 - 179)
        angle -= 90.0;
        double radians = DEGREES_TO_RADIANS(angle);
        double sinValue = sin(radians);
        double cosValue = cos(radians);
        double x = cosValue * strokeLength;
        double y = sinValue * strokeLength;
        self.endingPoint = NSMakePoint(startingPoint.point.x + x,
                                       startingPoint.point.y + y);
    } else {
        // 1st quadrant (0 - 89)
        double radians = DEGREES_TO_RADIANS(angle);
        double sinValue = sin(radians);
        double cosValue = cos(radians);
        double x = sinValue * strokeLength;
        double y = cosValue * strokeLength;
        self.endingPoint = NSMakePoint(startingPoint.point.x + x,
                                       startingPoint.point.y - y);
    }
}

//******************************************************************************

@end
