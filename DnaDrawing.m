//
//  DnaDrawing.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import "DnaDrawing.h"
#import "DnaPolygon.h"
#import "DnaBrushStroke.h"
#import "Settings.h"
#import "Tools.h"


@implementation DnaDrawing

@synthesize listBrushStrokes;
@synthesize listPolygons;
@synthesize isDirty;

//******************************************************************************

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        self.listPolygons = [aDecoder decodeObjectForKey:@"listPolygons"];
        self.listBrushStrokes = [aDecoder decodeObjectForKey:@"listBrushStrokes"];
        isDirty = [aDecoder decodeBoolForKey:@"isDirty"];
        drawingSize = [aDecoder decodeSizeForKey:@"drawingSize"];
        _polygonCount = [self.listPolygons count];
    }
    
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:listPolygons forKey:@"listPolygons"];
    [aCoder encodeObject:listBrushStrokes forKey:@"listBrushStrokes"];
    [aCoder encodeBool:isDirty forKey:@"isDirty"];
    [aCoder encodeSize:drawingSize forKey:@"drawingSize"];
}

//******************************************************************************

- (id)initWithSize:(NSSize)theDrawingSize {
   self = [super init];
   if (self) {
       settings = [Settings instance];
       const int activePolygonsMin = settings.activePolygonsMin;

      NSMutableArray* aList =
         [[NSMutableArray alloc] initWithCapacity:activePolygonsMin];
      self.listPolygons = aList;
      [aList release];
       
       aList = [[NSMutableArray alloc] initWithCapacity:activePolygonsMin];
       self.listBrushStrokes = aList;
       [aList release];
       
      isDirty = YES;
      tools = [Tools instance];
      drawingSize = theDrawingSize;
      
      for (int i = 0; i < activePolygonsMin; ++i) {
         [self addPolygon];
         [self addBrushStroke];
      }
       
       _polygonCount = [self.listPolygons count];
       _brushStrokeCount = [self.listBrushStrokes count];
   }
   
   return self;
}

//******************************************************************************

- (DnaDrawing*)initAsCloneFromDrawing:(DnaDrawing*)cloneFrom {
   self = [super init];
   if (self) {
      NSUInteger numPolygons = [cloneFrom.listPolygons count];
      NSUInteger numBrushStrokes = [cloneFrom.listBrushStrokes count];
      NSMutableArray* aList = 
         [[NSMutableArray alloc] initWithCapacity:numPolygons];
      isDirty = NO;
      settings = [Settings instance];
      tools = [Tools instance];
      drawingSize = cloneFrom->drawingSize;

      DnaPolygon* newPolygon;
   
      for (DnaPolygon* oldPolygon in cloneFrom.listPolygons) {
         newPolygon = [[DnaPolygon alloc] initAsCloneFromPolygon:oldPolygon];
         [aList addObject:newPolygon];
         [newPolygon release];
      }
      
      self.listPolygons = aList;
      [aList release];
       _polygonCount = [self.listPolygons count];
       
       aList = [[NSMutableArray alloc] initWithCapacity:numBrushStrokes];
       
       DnaBrushStroke* newBrushStroke;
       
       for (DnaBrushStroke* oldBrushStroke in cloneFrom.listBrushStrokes) {
           newBrushStroke =
              [[DnaBrushStroke alloc] initAsCloneFromBrushStroke:oldBrushStroke];
           [aList addObject:newBrushStroke];
           [newBrushStroke release];
       }
       self.listBrushStrokes = aList;
       [aList release];

       _brushStrokeCount = [self.listBrushStrokes count];
   }
   
   return self;
}

//******************************************************************************

- (void)dealloc {
   self.listPolygons = nil;
    self.listBrushStrokes = nil;
   [super dealloc];
}

//******************************************************************************

- (NSUInteger)getPointCount {
   NSUInteger pointCount = 0;
   
   for (DnaPolygon* polygon in listPolygons) {
      pointCount += [polygon getPointCount];
   }

   return pointCount;
}

//******************************************************************************

- (NSUInteger)getPolygonCount {
    return _polygonCount;
}

//******************************************************************************

- (void)mutate {
    int numOps = 0;
    int maxOps = [tools getRandomNumberWithMin:1 andMaximum:5];
    
    if ([tools willMutate:settings.activeAddPolygonMutationRate]) {
        [self addPolygon];
        ++numOps;
    }

    if (numOps < maxOps) {
        if ([tools willMutate:settings.activeRemovePolygonMutationRate]) {
            [self removePolygon];
            ++numOps;
        }
    }
    
    if (numOps < maxOps) {
        if ([tools willMutate:settings.activeMovePolygonMutationRate]) {
            [self movePolygon];
            ++numOps;
        }
    }
    
    if (numOps < maxOps) {
        for (DnaPolygon* polygon in listPolygons) {
            [polygon mutate:self];
        }
        ++numOps;
    }
    
    if (numOps < maxOps) {
        for (DnaBrushStroke* brushStroke in listBrushStrokes) {
            [brushStroke mutate:self];
        }
        ++numOps;
    }
}

//******************************************************************************

- (void)movePolygon {
   if (_polygonCount > 1) {
      // randomly select a polygon from list
      int index = -1;
      while ((index < 0) || (index >= _polygonCount)) {
         index = [tools getRandomNumberWithMin:0 andMaximum:(int)_polygonCount];
      }
      
      const int randomDeleteIndex = index;
      
      index = -1;
      while ((index < 0) ||
             (index >= _polygonCount) ||
             (index == randomDeleteIndex)) {
         index = [tools getRandomNumberWithMin:0 andMaximum:(int)_polygonCount];
      }
      
      const int randomInsertIndex = index;
      
      // move it to another randomly selected location in list
      [listPolygons insertObject:[listPolygons objectAtIndex:randomDeleteIndex]
						 atIndex:randomInsertIndex];
      [listPolygons removeObjectAtIndex:randomDeleteIndex];
       isDirty = YES;
   }
}

//******************************************************************************

- (void)removePolygon {
   if (_polygonCount > settings.activePolygonsMin) {
      // remove random polygon
      int randomDeleteIndex = -1;
      
      while ((randomDeleteIndex < 0) || (randomDeleteIndex >= _polygonCount)) {
         randomDeleteIndex =
            [tools getRandomNumberWithMin:0 andMaximum:(int)_polygonCount-1];
      }
      [listPolygons removeObjectAtIndex:randomDeleteIndex];
       --_polygonCount;
      isDirty = YES;
   }
}

//******************************************************************************

- (void)addPolygon {
   if (_polygonCount < settings.activePolygonsMax) {
      DnaPolygon* newPolygon = [[DnaPolygon alloc] initWithSize:drawingSize];
      
      // insert in random location
      const int randomInsertIndex =
         [tools getRandomNumberWithMin:0 andMaximum:(int)_polygonCount-1];
      [listPolygons insertObject:newPolygon atIndex:randomInsertIndex];
      isDirty = YES;
       ++_polygonCount;
      
      [newPolygon release];
   }
}

//******************************************************************************

- (NSUInteger)getBrushStrokeCount {
    return _brushStrokeCount;
}

//******************************************************************************

- (void)addBrushStroke {
    DnaBrushStroke* newBrushStroke =
        [[DnaBrushStroke alloc] initWithSize:drawingSize];
    
    // insert in random location
    const int randomInsertIndex =
        [tools getRandomNumberWithMin:0 andMaximum:(int)_brushStrokeCount-1];
    [listBrushStrokes insertObject:newBrushStroke atIndex:randomInsertIndex];
    isDirty = YES;
    ++_brushStrokeCount;
    
    [newBrushStroke release];
}

//******************************************************************************

- (void)removeBrushStroke {
    int randomDeleteIndex = -1;
    
    while ((randomDeleteIndex < 0) ||
           (randomDeleteIndex >= _brushStrokeCount)) {
        randomDeleteIndex =
            [tools getRandomNumberWithMin:0 andMaximum:(int)_brushStrokeCount-1];
    }
    [listBrushStrokes removeObjectAtIndex:randomDeleteIndex];
    --_brushStrokeCount;
    isDirty = YES;
}

//******************************************************************************

- (void)moveBrushStroke {
    if (_brushStrokeCount > 1) {
        // randomly select a brush stroke from list
        int index = -1;
        while ((index < 0) || (index >= _brushStrokeCount)) {
            index = [tools getRandomNumberWithMin:0
                                       andMaximum:(int)_brushStrokeCount];
        }
        
        const int randomDeleteIndex = index;
        
        index = -1;
        while ((index < 0) ||
               (index >= _brushStrokeCount) ||
               (index == randomDeleteIndex)) {
            index = [tools getRandomNumberWithMin:0
                                       andMaximum:(int)_brushStrokeCount];
        }
        
        const int randomInsertIndex = index;
        
        // move it to another randomly selected location in list
        [listBrushStrokes insertObject:[listBrushStrokes objectAtIndex:randomDeleteIndex]
                           atIndex:randomInsertIndex];
        [listBrushStrokes removeObjectAtIndex:randomDeleteIndex];
        isDirty = YES;
    }
}

//******************************************************************************

- (void)setSize:(NSSize)theDrawingSize {
   drawingSize = theDrawingSize;
   
   for (DnaPolygon* polygon in listPolygons) {
      [polygon setSize:drawingSize];
   }
}

//******************************************************************************

- (float)width {
    return drawingSize.width;
}

//******************************************************************************

- (float)height {
    return drawingSize.height;
}

//******************************************************************************

- (NSSize)drawingSize {
    return drawingSize;
}

//******************************************************************************

@end
