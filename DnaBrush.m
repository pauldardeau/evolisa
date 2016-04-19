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
        self.brushColor = [aDecoder decodeObjectForKey:@"brushColor"];
        red = [aDecoder decodeIntForKey:@"red"];
        green = [aDecoder decodeIntForKey:@"green"];
        blue = [aDecoder decodeIntForKey:@"blue"];
        alpha = [aDecoder decodeIntForKey:@"alpha"];
        
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
    [aCoder encodeObject:brushColor forKey:@"brushColor"];
    [aCoder encodeInt:red forKey:@"red"];
    [aCoder encodeInt:green forKey:@"green"];
    [aCoder encodeInt:blue forKey:@"blue"];
    [aCoder encodeInt:alpha forKey:@"alpha"];
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

@end
