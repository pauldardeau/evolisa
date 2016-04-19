//
//  DnaPolygon.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#include <math.h>

#import "DnaPolygon.h"
#import "DnaBrush.h"
#import "DnaDrawing.h"
#import "DnaPoint.h"
#import "Tools.h"
#import "Settings.h"

#define PI 3.14159265


@implementation DnaPolygon

@synthesize listPoints;
@synthesize brush;

//******************************************************************************

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        self.listPoints = [aDecoder decodeObjectForKey:@"listPoints"];
        self.brush = [aDecoder decodeObjectForKey:@"brush"];
    }
    
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:listPoints forKey:@"listPoints"];
    [aCoder encodeObject:brush forKey:@"brush"];
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
      
      const int numPoints = settings.activePointsPerPolygonMin;
      
      NSMutableArray* list =
         [[NSMutableArray alloc] initWithCapacity:numPoints];
      
      for (int i = 0; i < numPoints; ++i) {
         DnaPoint* point = [[DnaPoint alloc] initWithSize:theDrawingSize];
         [list addObject:point];
         [point release];
      }
      
      self.listPoints = list;
      [list release];
   }
   
   return self;
}

//******************************************************************************

- (DnaPolygon*)initAsCloneFromPolygon:(DnaPolygon*)cloneFrom {
   self = [super init];
   
   if (self) {
      DnaBrush* cloneBrush = cloneFrom.brush;
      DnaBrush* newBrush = [[DnaBrush alloc] initAsCloneFromBrush:cloneBrush];
      self.brush = newBrush;
      [newBrush release];

      settings = [Settings instance];
      tools = [Tools instance];
      
      NSUInteger numPoints = [cloneFrom.listPoints count];
      NSMutableArray* list =
         [[NSMutableArray alloc] initWithCapacity:numPoints];
      
      for (int i = 0; i < numPoints; ++i) {
         DnaPoint* oldPoint = [cloneFrom.listPoints objectAtIndex:i];
         DnaPoint* newPoint = [[DnaPoint alloc] initAsCloneFromPoint:oldPoint];
         [list addObject:newPoint];
         [newPoint release];
      }
      
      self.listPoints = list;
      [list release];
   }
   
   return self;
}

//******************************************************************************

- (void)dealloc {
   self.listPoints = nil;
   self.brush = nil;
   [super dealloc];
}

//******************************************************************************

- (NSUInteger)getPointCount {
   return [listPoints count];
}

//******************************************************************************

- (void)removePoint:(DnaDrawing*)drawing {
   if ([listPoints count] > settings.activePointsPerPolygonMin) {
      if ([drawing getPointCount] > settings.activePointsMin) {
         int index = -1;
         NSUInteger numberPoints = [listPoints count];
         while ((index < 0) || (index >= numberPoints)) {
            index = [tools getRandomNumberWithMin:0
                                       andMaximum:(int)numberPoints];
         }
         [listPoints removeObjectAtIndex:index];
         drawing.isDirty = YES;
      }
   }
}

//******************************************************************************

- (void)addPoint:(DnaDrawing*)drawing {
   if ([listPoints count] < settings.activePointsMax) {
      if ([drawing getPointCount] < settings.activePointsMax) {
         DnaPoint* newPoint = [[DnaPoint alloc] init];

         int index = -1;
         NSUInteger numberPoints = [listPoints count];
         while ((index < 0) || (index >= numberPoints)) {
            index = [tools getRandomNumberWithMin:1
                                       andMaximum:(int)numberPoints];
         }
         
         DnaPoint* prev = [listPoints objectAtIndex:index-1];
         DnaPoint* next = [listPoints objectAtIndex:index];
         
         newPoint.point =
            NSMakePoint((prev.point.x + next.point.x) / 2,
                        (prev.point.y + next.point.y) / 2);
         
         [listPoints insertObject:newPoint atIndex:index];
         drawing.isDirty = YES;
         [newPoint release];
      }
   }
}

//******************************************************************************

- (void)translate:(double)deltaX y:(double)deltaY {
   for (DnaPoint* dnaPoint in listPoints) {
      NSPoint preTranslatedPoint = dnaPoint.point;
      dnaPoint.point = NSMakePoint(preTranslatedPoint.x + deltaX,
                                   preTranslatedPoint.y + deltaY);
   }
}

//******************************************************************************

- (double)minXValue {
   NSUInteger numberPoints = [listPoints count];
   
   if (numberPoints < 1) {
      return 0.0;
   }
   
   DnaPoint* dnaPoint = [listPoints objectAtIndex:0];
   double minValue = dnaPoint.point.x;
   
   for (int i = 1; i < numberPoints; ++i) {
      dnaPoint = [listPoints objectAtIndex:i];
      if (dnaPoint.point.x < minValue) {
         minValue = dnaPoint.point.x;
      }
   }
   
   return minValue;
}

//******************************************************************************

- (double)maxXValue {
   NSUInteger numberPoints = [listPoints count];
   
   if (numberPoints < 1) {
      return 0.0;
   }
   
   DnaPoint* dnaPoint = [listPoints objectAtIndex:0];
   double maxValue = dnaPoint.point.x;
   
   for (int i = 1; i < numberPoints; ++i) {
      dnaPoint = [listPoints objectAtIndex:i];
      if (dnaPoint.point.x > maxValue) {
         maxValue = dnaPoint.point.x;
      }
   }
   
   return maxValue;
}

//******************************************************************************

- (double)minYValue {
   NSUInteger numberPoints = [listPoints count];
   
   if (numberPoints < 1) {
      return 0.0;
   }
   
   DnaPoint* dnaPoint = [listPoints objectAtIndex:0];
   double minValue = dnaPoint.point.y;
   
   for (int i = 1; i < numberPoints; ++i) {
      dnaPoint = [listPoints objectAtIndex:i];
      if (dnaPoint.point.y < minValue) {
         minValue = dnaPoint.point.y;
      }
   }
   
   return minValue;
}

//******************************************************************************

- (double)maxYValue
{
   NSUInteger numberPoints = [listPoints count];
   
   if (numberPoints < 1) {
      return 0.0;
   }
   
   DnaPoint* dnaPoint = [listPoints objectAtIndex:0];
   double maxValue = dnaPoint.point.y;
   
   for (int i = 1; i < numberPoints; ++i) {
      dnaPoint = [listPoints objectAtIndex:i];
      if (dnaPoint.point.y > maxValue) {
         maxValue = dnaPoint.point.y;
      }
   }
   
   return maxValue;
}

//******************************************************************************

- (void)translate:(DnaDrawing*)drawing {
   // horizontally -- shift left or right?
   const BOOL isLeftMovement = [tools randomBoolean];
   // vertically -- shift up or down?
   const BOOL isDownMovement = [tools randomBoolean];
   
   // figure out how much translation we'll perform horizontally & vertically
   double horzMaxMovement;
   double vertMaxMovement;
   
   if (isLeftMovement) {
      // don't want to cross left edge
      horzMaxMovement = [self minXValue];
   } else {
      // don't want to cross right edge
      horzMaxMovement = drawing.width - [self maxXValue];
   }
   
   if (isDownMovement) {
      // don't want to cross bottom edge
      vertMaxMovement = [self minYValue];
   } else {
      // don't want to cross top edge
      vertMaxMovement = drawing.height - [self maxYValue];
   }
   
   const int horzMaxMoveInt = (int) horzMaxMovement;
   const int vertMaxMoveInt = (int) vertMaxMovement;
   
   const int horzMoveAmt = [tools getRandomNumberWithMin:0
                                              andMaximum:horzMaxMoveInt];
   const int vertMoveAmt = [tools getRandomNumberWithMin:0
                                              andMaximum:vertMaxMoveInt];
   
   double deltaX = horzMoveAmt;
   double deltaY = vertMoveAmt;
   
   if (isLeftMovement) {
      deltaX = -deltaX;
   }
   
   if(isDownMovement) {
      deltaY = -deltaY;
   }
   
   [self translate:deltaX y:deltaY];
}

//******************************************************************************

- (void)rotate:(DnaDrawing*)drawing {
   // our reference point is the midpoint(x,y)
   NSUInteger numberPoints = [listPoints count];
   
   if (numberPoints < 3) {
      return;
   }
   
   // first, we find the midpoint
   DnaPoint* dnaPoint = [listPoints objectAtIndex:0];
   double pointX = dnaPoint.point.x;
   double pointY = dnaPoint.point.y;
   
   double minX = pointX;
   double minY = pointY;
   double maxX = pointX;
   double maxY = pointY;
   
   for (int i = 1; i < numberPoints; ++i) {
      dnaPoint = [listPoints objectAtIndex:i];
      pointX = dnaPoint.point.x;
      pointY = dnaPoint.point.y;
      
      if (pointX < minX) {
         minX = pointX;
      } else if (pointX > maxX) {
         maxX = pointX;
      }
      
      if (pointY < minY) {
         minY = pointY;
      } else if (pointY > maxY) {
         maxY = pointY;
      }
   }
   
   const double midX = (minX + maxX) / 2.0;
   const double midY = (minY + maxY) / 2.0;
   
   // translate so that we're centered at (0,0)
   DnaPolygon* transformedPolygon =
      [[DnaPolygon alloc] initAsCloneFromPolygon:self];
   [transformedPolygon translate:-midX y:-midY];
   
   const int rotationAngle = [tools getRandomNumberWithMin:1 andMaximum:359];
   const double rotationAngleAsDouble = rotationAngle * 1.0;
   
   const double rotationAngleInRadians = rotationAngleAsDouble / 180.0 * PI;
   
   const double sinAngle = sin(rotationAngleInRadians);
   const double cosAngle = cos(rotationAngleInRadians);
   
   for (DnaPoint* dnaPoint in transformedPolygon.listPoints) {
      NSPoint preRotatedPoint = dnaPoint.point;
      const double preRotatedX = preRotatedPoint.x;
      const double preRotatedY = preRotatedPoint.y;
      
      const double rotatedX = preRotatedX * cosAngle - preRotatedY * sinAngle;
      const double rotatedY = preRotatedX * sinAngle + preRotatedY * cosAngle;
      dnaPoint.point = NSMakePoint(rotatedX, rotatedY);
   }
   
   // we take on the list of rotated points as our new set of points
   self.listPoints = transformedPolygon.listPoints;
   
   // translate it back
   [transformedPolygon translate:midX y:midY];
   
   [transformedPolygon release];
}

//******************************************************************************

- (void)flipVertical:(DnaDrawing*)drawing {
   // flipping top and bottom halves (about the x axis)

   // how tall are we?
   const double minY = [self minYValue];
   const double maxY = [self maxYValue];
   const double midY = (minY + maxY) / 2.0;
   
   for (DnaPoint* dnaPoint in listPoints) {
      NSPoint point = dnaPoint.point;
      double y = point.y;
      double deltaY = midY - y;
      double flippedY = midY + deltaY;
      dnaPoint.point = NSMakePoint(point.x, flippedY);
   }
}

//******************************************************************************

- (void)flipHorizontal:(DnaDrawing*)drawing {
   // flipping left and right halves (about the y axis)

   // how wide are we?
   const double minX = [self minXValue];
   const double maxX = [self maxXValue];
   const double midX = (minX + maxX) / 2.0;

   for (DnaPoint* dnaPoint in listPoints) {
      NSPoint point = dnaPoint.point;
      double x = point.x;
      double deltaX = midX - x;
      double flippedX = midX + deltaX;
      dnaPoint.point = NSMakePoint(flippedX, point.y);
   }
}

//******************************************************************************

- (void)doubleFlip:(DnaDrawing*)drawing {
   if ([tools randomBoolean]) {
      [self flipVertical:drawing];
      [self flipHorizontal:drawing];
   } else {
      [self flipHorizontal:drawing];
      [self flipVertical:drawing];
   }
}

//******************************************************************************

- (void)mutate:(DnaDrawing*)drawing {
   /*
   if ([tools willMutate:settings.activeAddPointMutationRate]) {
      [self addPoint:drawing];
   }
   
   if ([tools willMutate:settings.activeRemovePointMutationRate]) {
      [self removePoint:drawing];
   }
    */
   
   BOOL vertFlipped = NO;
   BOOL horzFlipped = NO;
   
   if ([tools willMutate:settings.activeTranslationRate]) {
      [self translate:drawing];
   }

   if ([tools willMutate:settings.activeColorChangeRate]) {
      [brush mutate:drawing];
   }
   
   if ([tools willMutate:settings.activeRotationRate]) {
      [self rotate:drawing];
   }
   
   if ([tools willMutate:settings.activeFlipVerticalRate]) {
      vertFlipped = YES;
      [self flipVertical:drawing];
   }
   
   if ([tools willMutate:settings.activeFlipHorizontalRate]) {
      horzFlipped = YES;
      [self flipHorizontal:drawing];
   }
   
   if (!vertFlipped &&
       !horzFlipped &&
       [tools willMutate:settings.activeDoubleFlipRate]) {
      [self doubleFlip:drawing];
   }
   
   // mutations of individual point locations
   for (DnaPoint* point in listPoints) {
      [point mutate:drawing];
   }
}

//******************************************************************************

- (void)setSize:(NSSize)drawingSize {
   for (DnaPoint* point in listPoints) {
      [point setSize:drawingSize];
   }
}

//******************************************************************************

@end
