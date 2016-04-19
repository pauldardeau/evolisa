//
//  DnaBrush.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DnaDrawing;
@class Settings;
@class Tools;


@interface DnaBrush : NSObject <NSCoding>
{
   NSColor* brushColor;
   Settings* settings;
   Tools* tools;
   int red;
   int green;
   int blue;
   int alpha;
}

@property(nonatomic,retain) NSColor* brushColor;
@property(nonatomic) int red;
@property(nonatomic) int green;
@property(nonatomic) int blue;
@property(nonatomic) int alpha;


- (DnaBrush*)initAsCloneFromBrush:(DnaBrush*)cloneFrom;

- (void)mutate:(DnaDrawing*)drawing;

@end
