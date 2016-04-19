//
//  DnaBrushStroke.h
//  EvoLisa
//
//  Created by Paul Dardeau on 3/30/13.
//
//

#import <Foundation/Foundation.h>

@class DnaPoint;
@class DnaBrush;
@class Settings;
@class Tools;
@class DnaDrawing;


@interface DnaBrushStroke : NSObject <NSCoding>
{
    DnaPoint* startingPoint;
    NSPoint endingPoint;
    int angleDirection;
    int brushWidth;
    int strokeLength;
    DnaBrush* _brush;
    Settings* settings;
    Tools* tools;
}

@property(nonatomic,retain) DnaPoint* startingPoint;
@property(nonatomic) NSPoint endingPoint;
@property(nonatomic) int angleDirection;
@property(nonatomic) int brushWidth;
@property(nonatomic) int strokeLength;
@property(nonatomic,retain) DnaBrush* brush;

- (id)initWithSize:(NSSize)theDrawingSize;
- (DnaBrushStroke*)initAsCloneFromBrushStroke:(DnaBrushStroke*)cloneFrom;

- (void)mutate:(DnaDrawing*)drawing;
- (void)calculateEndingPoint;

@end
