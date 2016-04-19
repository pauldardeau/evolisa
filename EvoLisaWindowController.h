//
//  EvoLisaWindowController.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/16/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@class DrawingCanvas;
@class GLDrawingCanvas;
@class DnaDrawing;


typedef struct
{
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
} RGBA;


@interface EvoLisaWindowController : NSWindowController
{
    IBOutlet NSImageView* sourceImage;
    IBOutlet NSImageView* generatedImage;
    IBOutlet NSButton* generateButton;
    IBOutlet NSButton* stopButton;
    IBOutlet GLDrawingCanvas* glDrawingCanvas;
    IBOutlet DrawingCanvas* drawingCanvas;
    IBOutlet NSTextField* lblFitnessValue;
    IBOutlet NSTextField* lblGeneration;
   
    NSBitmapImageRep* sourceImageRep;
    NSString* userHomeDir;
    int sourceImageWidth;
    int sourceImageHeight;
    unsigned long long bestFitnessSoFar;
    BOOL haveAFitnessScore;
    DnaDrawing* currentDrawing;
    DnaDrawing* updatedDrawing;
    NSSize drawingSize;
    int generation;
    int selected;
    BOOL isRunning;
    RGBA* sourceChannelData;
    int numberBytes;
    BOOL usingOpenGL;
    NSDateFormatter* dateFormatter;
}

@property (nonatomic,retain) DnaDrawing* currentDrawing;
@property (nonatomic,retain) DnaDrawing* updatedDrawing;
@property (nonatomic,retain) NSString* userHomeDir;

- (IBAction)generateButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)loadButtonClicked:(id)sender;

- (void)notifyOnDrawingCanvasDrawn;
- (void)notifyAppTerminating;

@end
