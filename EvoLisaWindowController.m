//
//  EvoLisaWindowController.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/16/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import "EvoLisaWindowController.h"
#import "DrawingCanvas.h"
#import "GLDrawingCanvas.h"
#import "DnaDrawing.h"
#import "DnaPolygon.h"
#import "DnaBrush.h"
#import "DnaPoint.h"
#import "DnaBrushStroke.h"
#import "Tools.h"

#define USE_ALPHA_IN_FITNESS 1
//#define USE_VECTOR_OPS       1
//#define USE_BAIL_EARLY       1
//#define USE_TIMING           1

#ifdef _ppc_
vector unsigned char vecMax;
vector unsigned char vecMin;
vector unsigned char vecAbsDiff;
vector short vecZero = (vector short) (0,0,0,0,0,0,0,0);
#endif

typedef struct grayPixel
{
    unsigned char grayValue;
} GrayPixel;

typedef struct grayAlphaPixel
{
    unsigned char grayValue;
    unsigned char alphaValue;
} GrayAlphaPixel;

typedef struct rgbPixel
{
    unsigned char redValue;
    unsigned char greenValue;
    unsigned char blueValue;
} RGBPixel;

typedef struct rgbaPixel
{
    unsigned char redValue;
    unsigned char greenValue;
    unsigned char blueValue;
    unsigned char alphaValue;
} RGBAPixel;


//******************************************************************************

#ifdef _ppc_
void AlignData(unsigned char *input, vector unsigned char *output) {
    vector unsigned char perm; 
    vector unsigned char *unaligned_input; 
	
    unaligned_input = (vector unsigned char *) input; 
    perm = vec_lvsl( 0, input ); /* alignment amount */ 
    for (int i = 0; i < 16; ++i) {
		output[i] = vec_perm(unaligned_input[i], 
                             unaligned_input[i+1],
							 perm); 
	}
}
#endif

//******************************************************************************
//******************************************************************************

@implementation EvoLisaWindowController

@synthesize currentDrawing;
@synthesize updatedDrawing;
@synthesize userHomeDir;

//******************************************************************************

- (void)awakeFromNib {
   self.userHomeDir = NSHomeDirectory();
   usingOpenGL = YES;
    
   NSString* sourceImageDir = [NSString stringWithFormat:@"%@/paintings/",
                               self.userHomeDir];
   NSString* sourceFile = @"ml.png";
    
   NSString* sourceImagePath = [NSString stringWithFormat:@"%@%@",
                                sourceImageDir, sourceFile];
    
   NSImage* theSourceImage =
      [[NSImage alloc] initWithContentsOfFile:sourceImagePath];
    
   sourceImage.image = theSourceImage;
   [theSourceImage release];
    
/*
    NSImage* theFlippedSourceImage = [NSImage imageNamed:@"starry-night2.jpg"];

    if (usingOpenGL) {
        //[theFlippedSourceImage setFlipped:YES];
    }
    
   [theFlippedSourceImage lockFocus];
   sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[theFlippedSourceImage TIFFRepresentation]];
   //sourceImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:(NSRect){{0, 0}, theSourceImage.size}];
   [theFlippedSourceImage unlockFocus];
 */

   [theSourceImage lockFocus];
   sourceImageRep =
      [[NSBitmapImageRep alloc] initWithData:[theSourceImage TIFFRepresentation]];
   //sourceImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:(NSRect){{0, 0}, theSourceImage.size}];
   [theSourceImage unlockFocus];

   sourceImageWidth = theSourceImage.size.width;
   sourceImageHeight = theSourceImage.size.height;
   haveAFitnessScore = NO;
   generation = 0;
   selected = 0;
   [stopButton setEnabled:NO];
   isRunning = NO;
   
   NSWindow* window = [self window];
   NSView* contentView = [window contentView];
   NSRect contentViewSizePos = [contentView frame];
   const float contentViewHeight = contentViewSizePos.size.height;

   if (usingOpenGL) {
      glDrawingCanvas =
         [[GLDrawingCanvas alloc] initWithFrame:drawingCanvas.frame];
      [glDrawingCanvas setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
      glDrawingCanvas.windowController = self;
      [contentView addSubview:glDrawingCanvas];
      [drawingCanvas setHidden:YES];
       self.currentDrawing = glDrawingCanvas.drawing;
   } else {
       drawingCanvas.windowController = self;
       self.currentDrawing = drawingCanvas.drawing;
   }

   NSInteger pixelWidth = [sourceImageRep pixelsWide];
   NSInteger pixelHeight = [sourceImageRep pixelsHigh];
   
   NSLog(@"image height,width,height = %ld, %ld", pixelWidth, pixelHeight);
   NSLog(@"sourceImage height,width,height = %d, %d",
         sourceImageWidth, sourceImageHeight);
   
   const float canvasHeight = pixelHeight * 1.0;
   const float canvasTotalMargin = contentViewHeight - canvasHeight;
   
   float y = 0.0;
   
   if (canvasTotalMargin > 0.0) {
      // center it
      y = canvasTotalMargin / 2.0;
   } else {
      y = 0.0;
   }
   
    if (usingOpenGL) {
        NSRect canvasSizePos = [glDrawingCanvas frame];
        canvasSizePos.origin.y = y;
        canvasSizePos.size.width = pixelWidth;
        canvasSizePos.size.height = pixelHeight;
        drawingSize = canvasSizePos.size;
        [glDrawingCanvas setFrame:canvasSizePos];
    } else {
        NSRect canvasSizePos = [drawingCanvas frame];
        canvasSizePos.origin.y = y;
        canvasSizePos.size.width = pixelWidth;
        canvasSizePos.size.height = pixelHeight;
        drawingSize = canvasSizePos.size;
        [drawingCanvas setFrame:canvasSizePos];
    }
   
   const int numberPixels = sourceImageWidth * sourceImageHeight;
   numberBytes = numberPixels * sizeof(RGBA);
   sourceChannelData = (RGBA*) malloc(numberBytes);

   NSColor* sourcePixelColor;
   CGFloat red = 0.0;
   CGFloat green = 0.0;
   CGFloat blue = 0.0;
   CGFloat alpha = 0.0;
   RGBA* rgba = sourceChannelData;
   
   for (int row = 0; row < sourceImageHeight; ++row) {
      for (int col = 0; col < sourceImageWidth; ++col) {
         sourcePixelColor = [sourceImageRep colorAtX:col y:row];
         [sourcePixelColor getRed:&red green:&green blue:&blue alpha:&alpha];
         // color values between 0.0 - 1.0
         // convert to integer between 0-255
         rgba->red = 255 * red;
         rgba->green = 255 * green;
         rgba->blue = 255 * blue;
         rgba->alpha = 100 * alpha;

         ++rgba;
      }
   }
}

//******************************************************************************

- (void)dealloc {
   [sourceImageRep release];
   self.currentDrawing = nil;
   self.updatedDrawing = nil;
   self.userHomeDir = nil;
   free(sourceChannelData);
   [super dealloc];
}

//******************************************************************************

- (void)startGeneration {
   const int numIterations = 1;
   
   for (int i = 0; i < numIterations; ++i) {
      DnaDrawing* aNewDrawing =
         [[DnaDrawing alloc] initAsCloneFromDrawing:currentDrawing];
      [aNewDrawing mutate];
      
      if (aNewDrawing.isDirty) {
         ++generation;
         if (usingOpenGL) {
            glDrawingCanvas.drawing = aNewDrawing;
            [glDrawingCanvas display];
         } else {
            drawingCanvas.drawing = aNewDrawing;
            [drawingCanvas setNeedsDisplay:YES];
         }
      }
      
      [aNewDrawing release];
   }
   
   if (isRunning) {
      [NSTimer scheduledTimerWithTimeInterval:0.0001
									   target:self
									 selector:@selector(startGeneration)
									 userInfo:nil
									  repeats:NO];
   }
}

//******************************************************************************

- (IBAction)generateButtonClicked:(id)sender {
   NSLog( @"generate clicked" );
   isRunning = YES;
   [stopButton setEnabled:YES];
   [generateButton setEnabled:NO];
   
   [self startGeneration];
}

//******************************************************************************

- (IBAction)stopButtonClicked:(id)sender {
   NSLog(@"stop clicked");
   isRunning = NO;
   [stopButton setEnabled:NO];
   [generateButton setEnabled:YES];
}

//******************************************************************************

- (IBAction)saveButtonClicked:(id)sender {
    
   NSLog(@"save clicked");
   
   NSString* pathToSaveFile =
      [NSString stringWithFormat:@"%@/evolisa.txt", self.userHomeDir];
   
   FILE* f = fopen([pathToSaveFile UTF8String], "wt");
   
   if (f != NULL) {
      NSUInteger numPolygons = [currentDrawing.listPolygons count];

      fprintf(f, "width=%d\n", sourceImageWidth);
      fprintf(f, "height=%d\n", sourceImageHeight);
      fprintf(f, "generation=%d\n", selected);
      fprintf(f, "polygonCount=%ld\n", numPolygons);
      DnaBrush* brush;
      NSUInteger numPoints;
      int x;
      int y;
      
      for (DnaPolygon* polygon in currentDrawing.listPolygons) {
         brush = polygon.brush;
         
         numPoints = [polygon.listPoints count];
         fprintf(f, "pointCount=%ld", numPoints);
         fprintf(f, ";r=%d,g=%d,b=%d,a=%d",
                 brush.red, brush.green, brush.blue, brush.alpha);
         
         for (DnaPoint* point in polygon.listPoints) {
            x = (int) point.point.x;
            y = (int) point.point.y;
            
            fprintf(f, ";x=%d,y=%d", x, y);
         }

         fprintf(f, "\n");
      }
       
       NSUInteger numBrushStrokes = [currentDrawing.listBrushStrokes count];
       fprintf(f,"brushStrokeCount=%ld\n", numBrushStrokes);
       
       for (DnaBrushStroke* brushStroke in currentDrawing.listBrushStrokes) {
           brush = brushStroke.brush;
           
           fprintf(f, "r=%d,g=%d,b=%d,a=%d",
                   brush.red,
                   brush.green,
                   brush.blue,
                   brush.alpha);
           x = (int) brushStroke.startingPoint.point.x;
           y = (int) brushStroke.startingPoint.point.y;
           fprintf(f, ";x=%d,y=%d", x, y);
           fprintf(f, ";angle=%d;width=%d;length=%d",
                   brushStroke.angleDirection,
                   brushStroke.brushWidth,
                   brushStroke.strokeLength);
           
           fprintf(f, "\n");
       }
      
      fclose(f);
   }
}

//******************************************************************************

- (IBAction)loadButtonClicked:(id)sender {

   NSLog(@"load clicked");
   
   NSString* pathToSaveFile =
    [NSString stringWithFormat:@"%@/evolisa.txt", self.userHomeDir];

   FILE* f = fopen([pathToSaveFile UTF8String], "rt");
   
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
      
      fgets(lineBuffer, 2047, f);
      sscanf(lineBuffer, "generation=%d\n", &fileGeneration);

      fgets(lineBuffer, 2047, f );
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
               listPoints = [[NSMutableArray alloc] initWithCapacity:numPoints];
               
               pszCurrent = strchr( lineBuffer, ';' ) + 1;
               sscanf(pszCurrent, "r=%d,g=%d,b=%d,a=%d",
                      &red, &green, &blue, &alpha);
               pszCurrent = strchr( pszCurrent, ';' ) + 1;
               
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

         DnaDrawing* fileDrawing = [[DnaDrawing alloc] initWithSize:drawingSize];
         fileDrawing.listPolygons = listPolygons;
         [listPolygons release];
          
          fileDrawing.listBrushStrokes = listBrushStrokes;
          [listBrushStrokes release];
         
         self.currentDrawing = fileDrawing;
         [fileDrawing release];
         selected = fileGeneration;
         generation = fileGeneration;
      }
      
      fclose(f);
   }
}

//******************************************************************************

- (void)performTermination {
   NSLog( @"auto-saving file at termination" );
   [self saveButtonClicked:nil];
}

//******************************************************************************

- (void)notifyAppTerminating {
   if (isRunning) {
      isRunning = NO;
      [NSTimer scheduledTimerWithTimeInterval:0.2
                                       target:self
                                     selector:@selector(performTermination)
                                     userInfo:nil
                                      repeats:NO];
   }
}

//******************************************************************************

- (unsigned long long)gcdCompareImages:(NSBitmapImageRep*)imageRep {

#ifdef USE_BAIL_EARLY
    BOOL earlyBreak = NO;
#endif
    
#ifdef USE_TIMING
    NSDate* startCompareTime = [NSDate date];
#endif
    
    NSInteger samplesPerPixel = [imageRep samplesPerPixel];
    //GrayPixel* grayPixelData = NULL;
    //GrayAlphaPixel* grayAlphaPixelData = NULL;
    RGBPixel* rgbPixelData = NULL;
    RGBAPixel* rgbaPixelData = NULL;
    
    if (1 == samplesPerPixel) {
        //grayPixelData = (GrayPixel*) [imageRep bitmapData];
    } else if (2 == samplesPerPixel) {
        //grayAlphaPixelData = (GrayAlphaPixel*) [imageRep bitmapData];
    } else if (3 == samplesPerPixel) {
        rgbPixelData = (RGBPixel*) [imageRep bitmapData];
    } else if (4 == samplesPerPixel) {
        rgbaPixelData = (RGBAPixel*) [imageRep bitmapData];
    }
    
    double resultsArray[500];
    memset(resultsArray, 0, sizeof(resultsArray));
    __block double* results = resultsArray;
    
    if (4 == samplesPerPixel) {
        dispatch_apply(sourceImageHeight, dispatch_get_global_queue(0, 0), ^(size_t row){
            const size_t rowOffset = sourceImageWidth * row;
            const size_t rgbaOffset = rowOffset;  //row * sourceImageWidth;
            RGBA* rgba = sourceChannelData + rgbaOffset;
            unsigned long long rowFitness = 0L;
            
            for (int col = 0; col < sourceImageWidth; ++col) {
                RGBAPixel* pixel = &(rgbaPixelData[rowOffset + col]);
                int colorPixelFitness = abs(rgba->red - pixel->redValue);
                colorPixelFitness += abs(rgba->green - pixel->greenValue);
                colorPixelFitness += abs(rgba->blue - pixel->blueValue);
#ifdef USE_ALPHA_IN_FITNESS
                colorPixelFitness += abs(rgba->alpha - pixel->alphaValue);
#endif
                rowFitness += colorPixelFitness;
                ++rgba;
            }
            
            results[row] = rowFitness;
        });
    } else if (3 == samplesPerPixel) {
        dispatch_apply(sourceImageHeight, dispatch_get_global_queue(0, 0), ^(size_t row){
            const size_t rowOffset = sourceImageWidth * row;
            const size_t rgbaOffset = rowOffset;  //row * sourceImageWidth;
            RGBA* rgba = sourceChannelData + rgbaOffset;
            unsigned long long rowFitness = 0L;
            
            for (int col = 0; col < sourceImageWidth; ++col) {
                RGBPixel* pixel = &(rgbPixelData[rowOffset + col]);
                int colorPixelFitness = abs(rgba->red - pixel->redValue);
                colorPixelFitness += abs(rgba->green - pixel->greenValue);
                colorPixelFitness += abs(rgba->blue - pixel->blueValue);
                rowFitness += colorPixelFitness;
                ++rgba;
            }
            
            results[row] = rowFitness;
        });
    }

    unsigned long long fitness = 0L;

    //TODO: probably a much faster way of doing this using SIMD instructions
    if (haveAFitnessScore) {
       for (int row = 0; row < sourceImageHeight; ++row) {
          fitness += results[row];
          if (fitness >= bestFitnessSoFar) {
             break;
          }
       }
    } else {
        for (int row = 0; row < sourceImageHeight; ++row) {
            fitness += results[row];
        }
    }
    
#ifdef USE_TIMING
    NSTimeInterval elapsedTime = [startCompareTime timeIntervalSinceNow];
    NSLog(@"e.t. = %f, b.e. = %@", elapsedTime, earlyBreak ? @"Y" : @"N");
#endif
    
    return fitness;
}

//******************************************************************************

- (unsigned long long)compareImages:(NSBitmapImageRep*)imageRep {

   unsigned long long fitness = 0L;
   RGBA* rgba = sourceChannelData;
#ifdef USE_BAIL_EARLY
   BOOL earlyBreak = NO;
#endif
   
#ifdef USE_TIMING
   NSDate* startCompareTime = [NSDate date];
#endif
   
#ifdef _ppc_
	union
	{
		short s[8];
		vector short vSAD;
	} swap;
	
	union
	{
		unsigned char c[16];
		vector unsigned char vecSource;
	} buffSource;
	
	union
	{
		unsigned char c[16];
		vector unsigned char vecCandidate;
	} buffCandidate;
	
	swap.vSAD = (vector short) (0,0,0,0,0,0,0,0);

	buffCandidate.c[3] = 0;
	buffCandidate.c[7] = 0;
	buffCandidate.c[11] = 0;
	buffCandidate.c[15] = 0;
	
	buffSource.c[3] = 0;
	buffSource.c[7] = 0;
	buffSource.c[11] = 0;
	buffSource.c[15] = 0;

	int col;

#endif
    
    NSInteger samplesPerPixel = [imageRep samplesPerPixel];
    //GrayPixel* grayPixelData = NULL;
    //GrayAlphaPixel* grayAlphaPixelData = NULL;
    RGBPixel* rgbPixelData = NULL;
    RGBAPixel* rgbaPixelData = NULL;
    
    if (1 == samplesPerPixel) {
        //grayPixelData = (GrayPixel*) [imageRep bitmapData];
    } else if (2 == samplesPerPixel) {
        //grayAlphaPixelData = (GrayAlphaPixel*) [imageRep bitmapData];
    } else if (3 == samplesPerPixel) {
        rgbPixelData = (RGBPixel*) [imageRep bitmapData];
    } else if (4 == samplesPerPixel) {
        rgbaPixelData = (RGBAPixel*) [imageRep bitmapData];
    }
    
	
   for (int row = 0; row < sourceImageHeight; ++row) {
       const int rowOffset = sourceImageWidth * row;

#if defined(_ppc_) && defined(USE_VECTOR_OPS)
      for (col = 0; (col+4) < sourceImageWidth;) {
		  // Pixel 1
          RGBAPixel* pixel = &(rgbaPixelData[rowOffset + col]);
		  buffCandidate.c[0] = pixel->redValue;
		  buffCandidate.c[1] = pixel->greenValue;
		  buffCandidate.c[2] = pixel->blueValue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffCandidate.c[3] = 100 * alpha;
#endif
		  ++col;
		  
		  
		  // Pixel 2
          //RGBAPixel* pixel = &(rgbaPixelData[rowOffset + col]);
          ++pixel;
		  buffCandidate.c[4] = pixel->redValue;
		  buffCandidate.c[5] = pixel->greenValue;
		  buffCandidate.c[6] = pixel->blueValue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffCandidate.c[7] = 100 * alpha;
#endif
		  ++col;
		  
		  
		  // Pixel 3
          ++pixel;
		  buffCandidate.c[8] = pixel->redValue;
		  buffCandidate.c[9] = pixel->greenValue;
		  buffCandidate.c[10] = pixel->blueValue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffCandidate.c[11] = 100 * alpha;
#endif
		  ++col;
		  
		  
		  // Pixel 4
		  ++pixel;
		  buffCandidate.c[12] = pixel->redValue;
		  buffCandidate.c[13] = pixel->greenValue;
		  buffCandidate.c[14] = pixel->blueValue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffCandidate.c[15] = 100 * alpha;
#endif
		  ++col;
		  
		  
		  // Set up source data
		  buffSource.c[0] = rgba->red;
		  buffSource.c[1] = rgba->green;
		  buffSource.c[2] = rgba->blue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffSource.c[3] = rgba->alpha;
#endif
		  ++rgba;
		  
		  buffSource.c[4] = rgba->red;
		  buffSource.c[5] = rgba->green;
		  buffSource.c[6] = rgba->blue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffSource.c[7] = rgba->alpha;
#endif
		  ++rgba;
		  
		  buffSource.c[8] = rgba->red;
		  buffSource.c[9] = rgba->green;
		  buffSource.c[10] = rgba->blue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffSource.c[11] = rgba->alpha;
#endif
		  ++rgba;
		  
		  buffSource.c[12] = rgba->red;
		  buffSource.c[13] = rgba->green;
		  buffSource.c[14] = rgba->blue;
#ifdef USE_ALPHA_IN_FITNESS
		  buffSource.c[15] = rgba->alpha;
#endif
		  ++rgba;
		  
		  vecMax = vec_max(buffSource.vecSource, buffCandidate.vecCandidate);
		  vecMin = vec_min(buffSource.vecSource, buffCandidate.vecCandidate);
		  vecAbsDiff = vec_sub(vecMax, vecMin);
		  swap.vSAD = vec_sums(vec_sum4s(vecAbsDiff, vecZero), vecZero);
		  fitness += swap.s[7];
	  }
	   
      for (; col < sourceImageWidth; ++col) {
         RGBAPixel* pixel = &(rgbaPixelData[rowOffset + col]);
         colorPixelFitness = abs(rgba->red - pixel->redValue);
         colorPixelFitness += abs(rgba->green - pixel->greenValue);
         colorPixelFitness += abs(rgba->blue - pixel->blueValue);
#ifdef USE_ALPHA_IN_FITNESS
         colorPixelFitness += abs(rgba->alpha - pixel->alphaValue);
#endif
         fitness += colorPixelFitness;
         ++rgba;
      }
#else
       if (4 == samplesPerPixel) {
           for (int col = 0; col < sourceImageWidth; ++col) {
               RGBAPixel* pixel = &(rgbaPixelData[rowOffset + col]);
               int colorPixelFitness = abs(rgba->red - pixel->redValue);
               colorPixelFitness += abs(rgba->green - pixel->greenValue);
               colorPixelFitness += abs(rgba->blue - pixel->blueValue);
#ifdef USE_ALPHA_IN_FITNESS
               colorPixelFitness += abs(rgba->alpha - pixel->alphaValue);
#endif
               fitness += colorPixelFitness;
               ++rgba;
           }
       } else if (3 == samplesPerPixel) {
           for (int col = 0; col < sourceImageWidth; ++col) {
               RGBPixel* pixel = &(rgbPixelData[rowOffset + col]);
               int colorPixelFitness = abs(rgba->red - pixel->redValue);
               colorPixelFitness += abs(rgba->green - pixel->greenValue);
               colorPixelFitness += abs(rgba->blue - pixel->blueValue);
               fitness += colorPixelFitness;
               ++rgba;
           }
       } else if( 2 == samplesPerPixel ) {
           
       } else if( 1 == samplesPerPixel ) {
           
       }
		
       /*
      for( int col = 0; col < sourceImageWidth; ++col )
      {
		  NSColor* generatedPixelColor = [imageRep colorAtX:col y:row];
		  [generatedPixelColor getRed:&red green:&green blue:&blue alpha:&alpha];
		  
		  int colorPixelFitness = abs(rgba->red - (255 * red));
		  colorPixelFitness += abs(rgba->green - (255 * green));
		  colorPixelFitness += abs(rgba->blue - (255 * blue));
		  colorPixelFitness += abs(rgba->alpha - (100 * alpha));
		  fitness += colorPixelFitness;
		  ++rgba;
      }
        */
#endif
      
#ifdef USE_BAIL_EARLY
      if (haveAFitnessScore && (fitness > bestFitnessSoFar)) {
         //NSLog( @"--- bailing early" );
         earlyBreak = YES;
         break;
      }
#endif
   }
   
#ifdef USE_TIMING
   NSTimeInterval elapsedTime = [startCompareTime timeIntervalSinceNow];
   NSLog(@"e.t. = %f, b.e. = %@", elapsedTime, earlyBreak ? @"Y" : @"N");
#endif
   
   return fitness;
}

//******************************************************************************

- (void)notifyOnDrawingCanvasDrawn {
    
    NSBitmapImageRep* imageRep;
    BOOL imageRepAllocated = NO;
    NSRect canvasBounds;
    
    if (usingOpenGL) {
        canvasBounds = [glDrawingCanvas bounds];
        imageRep = [glDrawingCanvas bitmapImageRepFromView];
    } else {
        canvasBounds = [drawingCanvas bounds];
        [drawingCanvas lockFocus];
        imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:canvasBounds];
        [drawingCanvas unlockFocus];
        imageRepAllocated = YES;
    }

   BOOL isImprovement = NO;

   // compare
   unsigned long long fitness = [self gcdCompareImages:imageRep];

   if (haveAFitnessScore) {
      if (fitness < bestFitnessSoFar) {
         isImprovement = YES;
      }
   } else {
      haveAFitnessScore = YES;
      bestFitnessSoFar = fitness;
      isImprovement = YES;
   }

   //NSLog(@"bestFitnessSoFar = %lld, fitness = %lld", bestFitnessSoFar, fitness);

   // is it an improvement?
   if (isImprovement) {
      ++selected;
       
       lblFitnessValue.stringValue = [NSString stringWithFormat:@"%lld", fitness];
       lblGeneration.stringValue = [NSString stringWithFormat:@"%d (%ld)",
                                    selected,
                                    [self.currentDrawing getPolygonCount]];
       
       [lblFitnessValue setNeedsDisplay:YES];
       [lblGeneration setNeedsDisplay:YES];
       
      //NSLog( @"*** fit = %lld, gen=%d", fitness, selected );
      
       //TODO: this is not right for OpenGL - only use for Cocoa
      if (!usingOpenGL) {
         NSImage* image = [[NSImage alloc] initWithSize:canvasBounds.size];
         [image addRepresentation:imageRep];

         // show improved image
         generatedImage.image = image;
         [image release];
      }
      
      bestFitnessSoFar = fitness;
      
      if (usingOpenGL) {
         self.currentDrawing = glDrawingCanvas.drawing;
      } else {
         self.currentDrawing = drawingCanvas.drawing;
      }
   }
   
   if (imageRepAllocated) {
      [imageRep release];
   }
}

//******************************************************************************

@end
