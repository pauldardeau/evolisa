//
//  Settings.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface Settings : NSObject
{
    int addPointMutationRate;
    int addPolygonMutationRate;
    int alphaMutationRate;
    int alphaRangeMax;
    int alphaRangeMin;
    int blueMutationRate;
    int blueRangeMax;
    int blueRangeMin;
    int greenMutationRate;
    int greenRangeMax;
    int greenRangeMin;
    int movePointMaxMutationRate;
    int movePointMidMutationRate;
    int movePointMinMutationRate;
    int movePointRangeMid;
    int movePointRangeMin;
    int movePolygonMutationRate;
    int pointsMax;
    int pointsMin;
    int pointsPerPolygonMax;
    int pointsPerPolygonMin;
    int polygonsMax;
    int polygonsMin;
    int redMutationRate;
    int redRangeMax;
    int redRangeMin;
    int removePointMutationRate;
    int removePolygonMutationRate;
   
    int activeAddPointMutationRate;
    int activeAddPolygonMutationRate;
    int activeAlphaMutationRate;
    int activeAlphaRangeMax;
    int activeAlphaRangeMin;
    int activeBlueMutationRate;
    int activeBlueRangeMax;
    int activeBlueRangeMin;
    int activeGreenMutationRate;
    int activeGreenRangeMax;
    int activeGreenRangeMin;
    int activeMovePointMaxMutationRate;
    int activeMovePointMidMutationRate;
    int activeMovePointMinMutationRate;

    int activeMovePointRangeMid;
    int activeMovePointRangeMin;
    int activeMovePolygonMutationRate;
    int activePointsMax;
    int activePointsMin;
    int activePointsPerPolygonMax;
    int activePointsPerPolygonMin;
    int activePolygonsMax;
    int activePolygonsMin;
    int activeRedMutationRate;
    int activeRedRangeMax;
    int activeRedRangeMin;
    int activeRemovePointMutationRate;
    int activeRemovePolygonMutationRate;
   
    int activeColorChangeRate;
    int activeRotationRate;
    int activeTranslationRate;
    int activeFlipVerticalRate;
    int activeFlipHorizontalRate;
    int activeDoubleFlipRate;
}

@property (nonatomic) int redMutationRate;
@property (nonatomic) int greenMutationRate;
@property (nonatomic) int blueMutationRate;
@property (nonatomic) int alphaMutationRate;
@property (nonatomic) int movePointMaxMutationRate;
@property (nonatomic) int movePointMidMutationRate;
@property (nonatomic) int movePointMinMutationRate;
@property (nonatomic) int addPointMutationRate;
@property (nonatomic) int removePointMutationRate;
@property (nonatomic) int addPolygonMutationRate;
@property (nonatomic) int removePolygonMutationRate;
@property (nonatomic) int movePolygonMutationRate;

@property (nonatomic) int activeAddPointMutationRate;
@property (nonatomic) int activeAddPolygonMutationRate;
@property (nonatomic) int activeAlphaMutationRate;
@property (nonatomic) int activeAlphaRangeMax;
@property (nonatomic) int activeAlphaRangeMin;
@property (nonatomic) int activeBlueMutationRate;
@property (nonatomic) int activeBlueRangeMax;
@property (nonatomic) int activeBlueRangeMin;
@property (nonatomic) int activeGreenMutationRate;
@property (nonatomic) int activeGreenRangeMax;
@property (nonatomic) int activeGreenRangeMin;
@property (nonatomic) int activeMovePointMaxMutationRate;
@property (nonatomic) int activeMovePointMidMutationRate;
@property (nonatomic) int activeMovePointMinMutationRate;

@property (nonatomic) int activeMovePointRangeMid;
@property (nonatomic) int activeMovePointRangeMin;
@property (nonatomic) int activeMovePolygonMutationRate;
@property (nonatomic) int activePointsMax;
@property (nonatomic) int activePointsMin;
@property (nonatomic) int activePointsPerPolygonMax;
@property (nonatomic) int activePointsPerPolygonMin;
@property (nonatomic) int activePolygonsMax;
@property (nonatomic) int activePolygonsMin;
@property (nonatomic) int activeRedMutationRate;
@property (nonatomic) int activeRedRangeMax;
@property (nonatomic) int activeRedRangeMin;
@property (nonatomic) int activeRemovePointMutationRate;
@property (nonatomic) int activeRemovePolygonMutationRate;

@property (nonatomic) int activeColorChangeRate;
@property (nonatomic) int activeRotationRate;
@property (nonatomic) int activeTranslationRate;
@property (nonatomic) int activeFlipVerticalRate;
@property (nonatomic) int activeFlipHorizontalRate;
@property (nonatomic) int activeDoubleFlipRate;


+ (Settings*)instance;

- (void)setRedRangeMin:(int)value;
- (void)setRedRangeMax:(int)value;
- (void)setGreenRangeMin:(int)value;
- (void)setGreenRangeMax:(int)value;
- (void)setBlueRangeMin:(int)value;
- (void)setBlueRangeMax:(int)value;
- (void)setAlphaRangeMin:(int)value;
- (void)setAlphaRangeMax:(int)value;

- (void)setPolygonsMin:(int)value;
- (void)setPolygonsMax:(int)value;
- (void)setPointsPerPolygonMin:(int)value;
- (void)setPointsPerPolygonMax:(int)value;
- (void)setPointsMin:(int)value;
- (void)setPointsMax:(int)value;
- (void)setMovePointRangeMin:(int)value;
- (void)setMovePointRangeMid:(int)value;

- (void)activate;
- (void)discard;
- (void)reset;

@end
