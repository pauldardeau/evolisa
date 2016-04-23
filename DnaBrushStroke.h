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
    NSInteger angleDirection;
    NSInteger brushWidth;
    NSInteger strokeLength;
    DnaBrush* brush;
    Settings* settings;
    Tools* tools;
}

@property (nonatomic,retain) DnaPoint* startingPoint;
@property (nonatomic) NSPoint endingPoint;
@property (nonatomic) NSInteger angleDirection;
@property (nonatomic) NSInteger brushWidth;
@property (nonatomic) NSInteger strokeLength;
@property (nonatomic,retain) DnaBrush* brush;

- (id)initWithSize:(NSSize)theDrawingSize;
- (DnaBrushStroke*)initAsCloneFromBrushStroke:(DnaBrushStroke*)cloneFrom;

- (void)mutate:(DnaDrawing*)drawing;
- (void)calculateEndingPoint;

- (NSDictionary*)toDictionary;
+ (DnaBrushStroke*)fromDictionary:(NSDictionary*)dict;

- (BOOL)isEqualToBrushStroke:(DnaBrushStroke*)other;

@end
