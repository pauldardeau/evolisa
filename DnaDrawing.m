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
#import "DnaPoint.h"
#import "DnaBrush.h"
#import "Settings.h"
#import "Tools.h"


static NSString* KEY_POLYGONS = @"listPolygons";
static NSString* KEY_BRUSH_STROKES = @"listBrushStrokes";
static NSString* KEY_IS_DIRTY = @"isDirty";
static NSString* KEY_DRAWING_SIZE = @"drawingSize";
static NSString* KEY_GENERATION = @"generation";


@implementation DnaDrawing

@synthesize listBrushStrokes;
@synthesize listPolygons;
@synthesize isDirty;
@synthesize generation;
@synthesize drawingSize;

//******************************************************************************

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        settings = [Settings instance];
        tools = [Tools instance];
        self.listPolygons = [aDecoder decodeObjectForKey:KEY_POLYGONS];
        self.listBrushStrokes = [aDecoder decodeObjectForKey:KEY_BRUSH_STROKES];
        isDirty = [aDecoder decodeBoolForKey:KEY_IS_DIRTY];
        drawingSize = [aDecoder decodeSizeForKey:KEY_DRAWING_SIZE];
        _polygonCount = [self.listPolygons count];
        self.generation = [aDecoder decodeIntegerForKey:KEY_GENERATION];
    }
    return self;
}

//******************************************************************************

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:listPolygons forKey:KEY_POLYGONS];
    [aCoder encodeObject:listBrushStrokes forKey:KEY_BRUSH_STROKES];
    [aCoder encodeBool:isDirty forKey:KEY_IS_DIRTY];
    [aCoder encodeSize:drawingSize forKey:KEY_DRAWING_SIZE];
    [aCoder encodeInteger:self.generation forKey:KEY_GENERATION];
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
    /*
    DnaBrushStroke* newBrushStroke =
        [[DnaBrushStroke alloc] initWithSize:drawingSize];
    
    // insert in random location
    const int randomInsertIndex =
        [tools getRandomNumberWithMin:0 andMaximum:(int)_brushStrokeCount-1];
    [listBrushStrokes insertObject:newBrushStroke atIndex:randomInsertIndex];
    isDirty = YES;
    ++_brushStrokeCount;
    
    [newBrushStroke release];
     */
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

- (BOOL)saveToTextFile:(NSString*)filePath {
    BOOL success = NO;

    FILE* f = fopen([filePath UTF8String], "wt");
    
    if (f != NULL) {
        NSUInteger numPolygons = [self.listPolygons count];
        
        fprintf(f, "width=%d\n", (int) [self width]);
        fprintf(f, "height=%d\n", (int) [self height]);
        fprintf(f, "generation=%ld\n", (long)self.generation);
        fprintf(f, "polygonCount=%ld\n", numPolygons);
        DnaBrush* brush;
        NSUInteger numPoints;
        int x;
        int y;
        
        for (DnaPolygon* polygon in self.listPolygons) {
            brush = polygon.brush;
            
            numPoints = [polygon.listPoints count];
            fprintf(f, "pointCount=%ld", numPoints);
            fprintf(f, ";r=%ld,g=%ld,b=%ld,a=%ld",
                    brush.red, brush.green, brush.blue, brush.alpha);
            
            for (DnaPoint* point in polygon.listPoints) {
                x = (int) point.point.x;
                y = (int) point.point.y;
                
                fprintf(f, ";x=%d,y=%d", x, y);
            }
            
            fprintf(f, "\n");
        }
        
        NSUInteger numBrushStrokes = [self.listBrushStrokes count];
        fprintf(f,"brushStrokeCount=%ld\n", numBrushStrokes);
        
        for (DnaBrushStroke* brushStroke in self.listBrushStrokes) {
            brush = brushStroke.brush;
            
            fprintf(f, "r=%ld,g=%ld,b=%ld,a=%ld",
                    brush.red,
                    brush.green,
                    brush.blue,
                    brush.alpha);
            x = (int) brushStroke.startingPoint.point.x;
            y = (int) brushStroke.startingPoint.point.y;
            fprintf(f, ";x=%d,y=%d", x, y);
            fprintf(f, ";angle=%ld;width=%ld;length=%ld",
                    brushStroke.angleDirection,
                    brushStroke.brushWidth,
                    brushStroke.strokeLength);
            
            fprintf(f, "\n");
        }
        
        fclose(f);
        success = YES;
    }

    return success;
}

//******************************************************************************

- (BOOL)saveToJsonFile:(NSString*)filePath {
    BOOL success = NO;
    
    NSDictionary* dict = [self toDictionary];
    NSError* error;
    NSData* data =
        [NSJSONSerialization dataWithJSONObject:dict
                                        options:0
                                          error:&error];
    if (nil != data) {
        [data writeToFile:filePath atomically:YES];
        // verify serialization
        /*
        DnaDrawing* fileDrawing = [DnaDrawing readFromJsonFile:filePath];
        if (fileDrawing != nil) {
            if (![self isEqualToDrawing:fileDrawing]) {
                NSLog(@"drawings differ");
            }
        }
         */
    }
    
    return success;
}

//******************************************************************************

+ (DnaDrawing*)readFromTextFile:(NSString*)filePath {
    DnaDrawing* drawing = nil;
    FILE* f = fopen([filePath UTF8String], "rt");
    
    if (f != NULL) {
        int fileWidth = 0;
        int fileHeight = 0;
        int fileGeneration = 0;
        int filePolygonCount = 0;
        int fileBrushStrokeCount = 0;
        char lineBuffer[2048];
        NSMutableArray* listPolygons = nil;
        NSMutableArray* listPoints;
        NSMutableArray* listBrushStrokes = nil;
        
        fgets(lineBuffer, 2047, f);
        sscanf(lineBuffer, "width=%d\n", &fileWidth);
        
        //TODO: temporary hack
        //fileWidth = 200;
        
        fgets(lineBuffer, 2047, f);
        sscanf(lineBuffer, "height=%d\n", &fileHeight);
        
        //TODO: temporary hack
        //fileHeight = 200;
        
        NSSize drawingSize = NSMakeSize(fileWidth, fileHeight);
        
        fgets(lineBuffer, 2047, f);
        sscanf(lineBuffer, "generation=%d\n", &fileGeneration);
        
        fgets(lineBuffer, 2047, f);
        sscanf(lineBuffer, "polygonCount=%d\n", &filePolygonCount);
        const int numPolygons = filePolygonCount;
        
        if (numPolygons > 0) {
            listPolygons = [[NSMutableArray alloc] initWithCapacity:numPolygons];
            
            DnaPolygon* polygon;
            DnaPoint* point;
            DnaBrush* brush;
            int numPoints = 0;
            int x = 0;
            int y = 0;
            int red = 0;
            int green = 0;
            int blue = 0;
            int alpha = 0;
            int angle = 0;
            int width = 0;
            int length = 0;
            
            const char* pszCurrent;
            
            
            for (int i = 0; i < numPolygons; ++i) {
                fgets(lineBuffer, 2047, f);
                sscanf(lineBuffer, "pointCount=%d;", &numPoints);
                
                if (numPoints > 0) {
                    listPoints =
                    [[NSMutableArray alloc] initWithCapacity:numPoints];
                    
                    pszCurrent = strchr(lineBuffer, ';') + 1;
                    sscanf(pszCurrent, "r=%d,g=%d,b=%d,a=%d",
                           &red, &green, &blue, &alpha);
                    pszCurrent = strchr(pszCurrent, ';') + 1;
                    
                    polygon = [[DnaPolygon alloc] initWithSize:drawingSize];
                    
                    brush = [[DnaBrush alloc] init];
                    brush.red = red;
                    brush.green = green;
                    brush.blue = blue;
                    brush.alpha = alpha;
                    brush.brushColor = [NSColor colorWithDeviceRed:(red/255.0)
                                                             green:(green/255.0)
                                                              blue:(blue/255.0)
                                                             alpha:(alpha/100.0)];
                    
                    polygon.brush = brush;
                    [brush release];
                    
                    for (int j = 0; j < numPoints; ++j) {
                        sscanf(pszCurrent, "x=%d,y=%d", &x, &y);
                        pszCurrent = strchr(pszCurrent, ';') + 1;
                        
                        point = [[DnaPoint alloc] initWithSize:drawingSize];
                        point.point = NSMakePoint(x,y);
                        [listPoints addObject:point];
                        [point release];
                    }
                    
                    polygon.listPoints = listPoints;
                    [listPoints release];
                    
                    [listPolygons addObject:polygon];
                    [polygon release];
                }
            }
            
            fgets(lineBuffer, 2047, f);
            sscanf(lineBuffer, "brushStrokeCount=%d\n", &fileBrushStrokeCount);
            const int numBrushStrokes = fileBrushStrokeCount;
            
            if (numBrushStrokes > 0) {
                listBrushStrokes =
                [[NSMutableArray alloc] initWithCapacity:numBrushStrokes];
                
                for (int i = 0; i < numBrushStrokes; ++i) {
                    fgets(lineBuffer, 2047, f);
                    
                    if (9 == sscanf(lineBuffer,
                                    "r=%d,g=%d,b=%d,a=%d;x=%d,y=%d;angle=%d;width=%d;length=%d",
                                    &red, &green, &blue, &alpha,
                                    &x, &y,
                                    &angle,
                                    &width,
                                    &length)) {
                        DnaBrushStroke* brushStroke = [[DnaBrushStroke alloc] init];
                        brushStroke.angleDirection = angle;
                        brushStroke.brushWidth = width;
                        brushStroke.strokeLength = length;
                        
                        point = [[DnaPoint alloc] initWithSize:drawingSize];
                        point.point = NSMakePoint(x,y);
                        brushStroke.startingPoint = point;
                        [point release];
                        
                        [brushStroke calculateEndingPoint];
                        
                        brush = [[DnaBrush alloc] init];
                        brush.red = red;
                        brush.green = green;
                        brush.blue = blue;
                        brush.alpha = alpha;
                        brush.brushColor = [NSColor colorWithDeviceRed:(red/255.0)
                                                                 green:(green/255.0)
                                                                  blue:(blue/255.0)
                                                                 alpha:(alpha/100.0)];
                        
                        brushStroke.brush = brush;
                        [brush release];
                        
                        [listBrushStrokes addObject:brushStroke];
                        [brushStroke release];
                    }
                }
            }
            
            drawing = [[[DnaDrawing alloc] initWithSize:drawingSize] autorelease];
            drawing.listPolygons = listPolygons;
            [listPolygons release];
            
            drawing.listBrushStrokes = listBrushStrokes;
            [listBrushStrokes release];
            
            drawing.generation = fileGeneration;
        }
        
        fclose(f);
    }
    
    return drawing;
}

//******************************************************************************

+ (DnaDrawing*)readFromJsonFile:(NSString*)filePath {
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    DnaDrawing* drawing = nil;
    
    if (data != nil) {
        NSError* parsingError;
        NSDictionary* dict =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:0
                                              error:&parsingError];
        if (nil != dict) {
            drawing = [DnaDrawing fromDictionary:dict];
        }
    }
    
    return drawing;
}

//******************************************************************************

- (NSDictionary*)toDictionary {
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableArray* listDicts = [[NSMutableArray alloc] init];
    for (DnaPolygon* polygon in listPolygons) {
        [listDicts addObject:[polygon toDictionary]];
    }
    [dict setValue:listDicts forKey:KEY_POLYGONS];
    [listDicts release];
    listDicts = [[NSMutableArray alloc] init];
    for (DnaBrushStroke* brushStroke in listBrushStrokes) {
        [listDicts addObject:[brushStroke toDictionary]];
    }
    [dict setValue:listDicts forKey:KEY_BRUSH_STROKES];
    [listDicts release];
    [dict setValue:[NSNumber numberWithBool:isDirty] forKey:KEY_IS_DIRTY];
    [dict setValue:NSStringFromSize(drawingSize) forKey:KEY_DRAWING_SIZE];
    [dict setValue:[NSNumber numberWithInteger:self.generation]
            forKey:KEY_GENERATION];
    return dict;
}

//******************************************************************************

+ (DnaDrawing*)fromDictionary:(NSDictionary *)dict {
    DnaDrawing* drawing = [[[DnaDrawing alloc] init] autorelease];
    NSArray* listDicts = [dict valueForKey:KEY_POLYGONS];
    NSMutableArray* listPolygons = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in listDicts) {
        [listPolygons addObject:[DnaPolygon fromDictionary:dict]];
    }
    drawing.listPolygons = listPolygons;
    [listPolygons release];
    listDicts = [dict valueForKey:KEY_BRUSH_STROKES];
    NSMutableArray* listBrushStrokes = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in listDicts) {
        [listBrushStrokes addObject:[DnaBrushStroke fromDictionary:dict]];
    }
    drawing.listBrushStrokes = listBrushStrokes;
    [listBrushStrokes release];
    drawing.isDirty = [[dict valueForKey:KEY_IS_DIRTY] boolValue];
    drawing.drawingSize = NSSizeFromString([dict valueForKey:KEY_DRAWING_SIZE]);
    drawing.generation = [[dict valueForKey:KEY_DRAWING_SIZE] integerValue];
    return drawing;
}

//******************************************************************************

- (BOOL)isEqualToDrawing:(DnaDrawing*)other {
    NSUInteger polyCount = [self.listPolygons count];
    if (polyCount != [other.listPolygons count]) {
        NSLog(@"polygonCount differs");
        return NO;
    }
    
    for (NSUInteger i = 0; i < polyCount; ++i) {
        DnaPolygon* thisPoly = [self.listPolygons objectAtIndex:i];
        DnaPolygon* otherPoly = [other.listPolygons objectAtIndex:i];
        if (![thisPoly isEqualToPolygon:otherPoly]) {
            NSLog(@"polygon differs");
            return NO;
        }
    }
    
    NSUInteger strokeCount = [self.listBrushStrokes count];
    if (strokeCount != [other.listBrushStrokes count]) {
        NSLog(@"strokeCount differs");
        return NO;
    }
    
    for (NSUInteger i = 0; i < strokeCount; ++i) {
        DnaBrushStroke* thisStroke = [self.listBrushStrokes objectAtIndex:i];
        DnaBrushStroke* otherStroke = [other.listBrushStrokes objectAtIndex:i];
        if (![thisStroke isEqualToBrushStroke:otherStroke]) {
            NSLog(@"brush stroke differs");
            return NO;
        }
    }

    if (self.isDirty != other.isDirty) {
        NSLog(@"isDirty differs");
        return NO;
    }
    
    if (self.generation != other.generation) {
        NSLog(@"generation differs");
        return NO;
    }
    
    if ((self.drawingSize.height != other.drawingSize.height) ||
        (self.drawingSize.width != other.drawingSize.width)) {
        NSLog(@"drawingSize differs");
        return NO;
    }
    
    return YES;
}

//******************************************************************************

@end
