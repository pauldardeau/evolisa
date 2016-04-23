//
//  DnaBrush.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import "DnaBrush.h"
#import "DnaDrawing.h"
#import "Settings.h"
#import "Tools.h"


static NSString* KEY_BRUSH_COLOR = @"brushColor";
static NSString* KEY_RED = @"red";
static NSString* KEY_GREEN = @"green";
static NSString* KEY_BLUE = @"blue";
static NSString* KEY_ALPHA = @"alpha";


@implementation DnaBrush

@synthesize brushColor;
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize alpha;

//******************************************************************************

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        self.brushColor = [aDecoder decodeObjectForKey:KEY_BRUSH_COLOR];
        red = [aDecoder decodeIntForKey:KEY_RED];
        green = [aDecoder decodeIntForKey:KEY_GREEN];
        blue = [aDecoder decodeIntForKey:KEY_BLUE];
        alpha = [aDecoder decodeIntForKey:KEY_ALPHA];
        
        if (!brushColor) {
            self.brushColor =
                [NSColor colorWithDeviceRed:(red/255.0)
                                      green:(green/255.0)
                                       blue:(blue/255.0)
                                      alpha:(alpha/100.0)];
        }
    }
    
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:brushColor forKey:KEY_BRUSH_COLOR];
    [aCoder encodeInteger:red forKey:KEY_RED];
    [aCoder encodeInteger:green forKey:KEY_GREEN];
    [aCoder encodeInteger:blue forKey:KEY_BLUE];
    [aCoder encodeInteger:alpha forKey:KEY_ALPHA];
}

//******************************************************************************

- (id)init {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        red = [tools getRandomNumberWithMin:settings.activeRedRangeMin
                                 andMaximum:settings.activeRedRangeMax];
        green = [tools getRandomNumberWithMin:settings.activeGreenRangeMin
                                   andMaximum:settings.activeGreenRangeMax];
        blue = [tools getRandomNumberWithMin:settings.activeBlueRangeMin
                                  andMaximum:settings.activeBlueRangeMax];
        alpha = [tools getRandomNumberWithMin:settings.activeAlphaRangeMin
                                   andMaximum:settings.activeAlphaRangeMax];
        self.brushColor =
            [NSColor colorWithDeviceRed:(red/255.0)
                                  green:(green/255.0)
                                   blue:(blue/255.0)
                                  alpha:(alpha/100.0)];
    }
   
    return self;
}

//******************************************************************************

- (DnaBrush*)initAsCloneFromBrush:(DnaBrush*)cloneFrom {
    self = [super init];
    if (self) {
        DnaBrush* cloneBrush = (DnaBrush*)cloneFrom;
        settings = [Settings instance];
        tools = [Tools instance];
        red = cloneBrush.red;
        green = cloneBrush.green;
        blue = cloneBrush.blue;
        alpha = cloneBrush.alpha;
        self.brushColor =
            [NSColor colorWithDeviceRed:(red/255.0)
                                  green:(green/255.0)
                                   blue:(blue/255.0)
                                  alpha:(alpha/100.0)];
    }
   
    return self;
}

//******************************************************************************

- (void)dealloc {
    self.brushColor = nil;
    [super dealloc];
}

//******************************************************************************

- (void)mutate:(DnaDrawing*)drawing {
    BOOL isChanged = NO;
   
    if ([tools willMutate:settings.activeRedMutationRate]) {
        red = [tools getRandomNumberWithMin:settings.activeRedRangeMin
                                 andMaximum:settings.activeRedRangeMax];
        drawing.isDirty = YES;
        isChanged = YES;
    }
   
    if ([tools willMutate:settings.activeGreenMutationRate]) {
        green = [tools getRandomNumberWithMin:settings.activeGreenRangeMin
                                   andMaximum:settings.activeGreenRangeMax];
        drawing.isDirty = YES;
        isChanged = YES;
    }
    
    if ([tools willMutate:settings.activeBlueMutationRate]) {
        blue = [tools getRandomNumberWithMin:settings.activeBlueRangeMin
                                  andMaximum:settings.activeBlueRangeMax];
        drawing.isDirty = YES;
        isChanged = YES;
    }

    if ([tools willMutate:settings.activeAlphaMutationRate]) {
        alpha = [tools getRandomNumberWithMin:settings.activeAlphaRangeMin
                                   andMaximum:settings.activeAlphaRangeMax];
        drawing.isDirty = YES;
        isChanged = YES;
    }
   
    if (isChanged) {
        self.brushColor =
            [NSColor colorWithDeviceRed:(red/255.0)
                                  green:(green/255.0)
                                   blue:(blue/255.0)
                                  alpha:(alpha/100.0)];
    }
}

//******************************************************************************

- (NSDictionary*)toDictionary {
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    NSString* colorAsString = [NSString stringWithFormat:@"%d:%d:%d:%d",
                               (int) (brushColor.redComponent * 255),
                               (int) (brushColor.greenComponent * 255),
                               (int) (brushColor.blueComponent * 255),
                               (int) (brushColor.alphaComponent * 100)];
    [dict setValue:colorAsString forKey:KEY_BRUSH_COLOR];
    return dict;
}

//******************************************************************************

+ (DnaBrush*)fromDictionary:(NSDictionary *)dict {
    NSString* stringColor = [dict valueForKey:KEY_BRUSH_COLOR];
    if (nil != stringColor) {
        DnaBrush* brush = [[[DnaBrush alloc] init] autorelease];
        NSColor* brushColor;
        int components[4];
        memset(components, 0,  sizeof(components));
        NSArray* chunks = [stringColor componentsSeparatedByString:@":"];
        
        if ([chunks count] != 4) {
            brushColor = [NSColor blackColor];
        } else {
            for (int i = 0; i < 4; i++) {
                components[i] = [[chunks objectAtIndex:i] intValue];
            }
            brushColor = [NSColor colorWithDeviceRed:components[0]/255.0
                                               green:components[1]/255.0
                                                blue:components[2]/255.0
                                               alpha:components[3]/100.0];
        }
        brush.brushColor = brushColor;
        brush.red = components[0];
        brush.green = components[1];
        brush.blue = components[2];
        brush.alpha = components[3];
        return brush;
    } else {
        return nil;
    }
}

//******************************************************************************

- (BOOL)isEqualToBrush:(DnaBrush*)other {
    NSInteger alphaDelta = labs(self.alpha - other.alpha);
    if ((self.red != other.red) ||
        (self.green != other.green) ||
        (self.blue != other.blue) ||
        (alphaDelta > 1)) {
        NSLog(@"DnaBrush: color differs");
        NSLog(@"r: self=%ld, other=%ld", self.red, other.red);
        NSLog(@"g: self=%ld, other=%ld", self.green, other.green);
        NSLog(@"b: self=%ld, other=%ld", self.blue, other.blue);
        NSLog(@"a: self=%ld, other=%ld", self.alpha, other.alpha);
        return NO;
    }
    
    return YES;
}

//******************************************************************************

@end
