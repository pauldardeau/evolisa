//
//  DnaBrush.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
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
    NSInteger red;
    NSInteger green;
    NSInteger blue;
    NSInteger alpha;
}

@property (nonatomic,retain) NSColor* brushColor;
@property (nonatomic) NSInteger red;
@property (nonatomic) NSInteger green;
@property (nonatomic) NSInteger blue;
@property (nonatomic) NSInteger alpha;


- (DnaBrush*)initAsCloneFromBrush:(DnaBrush*)cloneFrom;

- (void)mutate:(DnaDrawing*)drawing;

- (NSDictionary*)toDictionary;
+ (DnaBrush*)fromDictionary:(NSDictionary*)dict;

- (BOOL)isEqualToBrush:(DnaBrush*)other;

@end
