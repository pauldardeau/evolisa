//
//  Settings.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import "Settings.h"


static const int MIN_COLOR_INTENSITY = 3;  // 1%
static const int MAX_COLOR_INTENSITY = 216;  // 85%

static const int MIN_ALPHA = 20;
static const int MAX_ALPHA = 70;

static const int MIN_POLYGONS = 50;
static const int MAX_POLYGONS = 650;

static Settings* instance = nil;


@implementation Settings

@synthesize redMutationRate;
@synthesize greenMutationRate;
@synthesize blueMutationRate;
@synthesize alphaMutationRate;
@synthesize movePointMaxMutationRate;
@synthesize movePointMidMutationRate;
@synthesize movePointMinMutationRate;
@synthesize addPointMutationRate;
@synthesize removePointMutationRate;
@synthesize removePolygonMutationRate;
@synthesize movePolygonMutationRate;
@synthesize addPolygonMutationRate;

@synthesize activeAddPointMutationRate;
@synthesize activeAddPolygonMutationRate;
@synthesize activeAlphaMutationRate;
@synthesize activeAlphaRangeMax;
@synthesize activeAlphaRangeMin;
@synthesize activeBlueMutationRate;
@synthesize activeBlueRangeMax;
@synthesize activeBlueRangeMin;
@synthesize activeGreenMutationRate;
@synthesize activeGreenRangeMax;
@synthesize activeGreenRangeMin;
@synthesize activeMovePointMaxMutationRate;
@synthesize activeMovePointMidMutationRate;
@synthesize activeMovePointMinMutationRate;

@synthesize activeMovePointRangeMid;
@synthesize activeMovePointRangeMin;
@synthesize activeMovePolygonMutationRate;
@synthesize activePointsMax;
@synthesize activePointsMin;
@synthesize activePointsPerPolygonMax;
@synthesize activePointsPerPolygonMin;
@synthesize activePolygonsMax;
@synthesize activePolygonsMin;
@synthesize activeRedMutationRate;
@synthesize activeRedRangeMax;
@synthesize activeRedRangeMin;
@synthesize activeRemovePointMutationRate;
@synthesize activeRemovePolygonMutationRate;

@synthesize activeColorChangeRate;
@synthesize activeRotationRate;
@synthesize activeTranslationRate;
@synthesize activeFlipVerticalRate;
@synthesize activeFlipHorizontalRate;
@synthesize activeDoubleFlipRate;


//******************************************************************************

+ (Settings*)instance {
    if (instance == nil) {
        instance = [[Settings alloc] init];
    }
   
    return instance;
}

//******************************************************************************

- (id)init {
    if ((self = [super init]) != nil) {
        activeAddPointMutationRate = 750;
        activeAddPolygonMutationRate = 700;
        activeAlphaMutationRate = 750;
        activeAlphaRangeMax = MAX_ALPHA;
        activeAlphaRangeMin = MIN_ALPHA;
        activeBlueMutationRate = 750;
        activeBlueRangeMin = MIN_COLOR_INTENSITY;
        activeBlueRangeMax = MAX_COLOR_INTENSITY;
        activeGreenMutationRate = 750;
        activeGreenRangeMin= MIN_COLOR_INTENSITY;
        activeGreenRangeMax = MAX_COLOR_INTENSITY;
        activeMovePointMaxMutationRate = 750;
        activeMovePointMidMutationRate = 750;
        activeMovePointMinMutationRate = 750;

        activeMovePointRangeMid = 20;
        activeMovePointRangeMin = 3;
        activeMovePolygonMutationRate = 700;
        activePointsMin = 0;
        activePointsMax = 2000;
        activePointsPerPolygonMax = 3;
        activePointsPerPolygonMin = 3;
        activePolygonsMin = MIN_POLYGONS;
        activePolygonsMax = MAX_POLYGONS;
        activeRedMutationRate = 750;
        activeRedRangeMin = MIN_COLOR_INTENSITY;
        activeRedRangeMax = MAX_COLOR_INTENSITY;
        activeRemovePointMutationRate = 750;
        activeRemovePolygonMutationRate = 750;
        addPointMutationRate = 750;
      
        addPolygonMutationRate = 700;
        alphaMutationRate = 750;
        alphaRangeMax = MAX_ALPHA;
        alphaRangeMin = MIN_ALPHA;
        blueMutationRate = 750;
        blueRangeMin = MIN_COLOR_INTENSITY;
        blueRangeMax = MAX_COLOR_INTENSITY;
        greenMutationRate = 750;
        greenRangeMin = MIN_COLOR_INTENSITY;
        greenRangeMax = MAX_COLOR_INTENSITY;
        movePointMaxMutationRate = 750;
        movePointMidMutationRate = 750;
        movePointMinMutationRate = 750;
        movePointRangeMid = 20;
        movePointRangeMin = 3;
        movePolygonMutationRate = 700;
        pointsMin = 0;
        pointsMax = 2000;
        pointsPerPolygonMax = 3;
        pointsPerPolygonMin = 3;
        polygonsMin = MIN_POLYGONS;
        polygonsMax = MAX_POLYGONS;
        redMutationRate = 750;
        redRangeMin = MIN_COLOR_INTENSITY;
        redRangeMax = MAX_COLOR_INTENSITY;
        removePointMutationRate = 750;
        removePolygonMutationRate = 700;
      
        activeColorChangeRate = 1000;
        activeRotationRate = 1000;
        activeTranslationRate = 1000;
        activeFlipVerticalRate = 1000;
        activeFlipHorizontalRate = 1000;
        activeDoubleFlipRate = 1000;

        [self reset];
    }
   
    return self;
}

//******************************************************************************

- (void)setRedRangeMin:(int)value {
    //TODO: setRedRangeMin
}

//******************************************************************************

- (void)setRedRangeMax:(int)value {
    //TODO: setRedRangeMax
}

//******************************************************************************

- (void)setGreenRangeMin:(int)value {
    //TODO: setGreenRangeMin
}

//******************************************************************************

- (void)setGreenRangeMax:(int)value {
    //TODO: setGreenRangeMax
}

//******************************************************************************

- (void)setBlueRangeMin:(int)value {
    //TODO: setBlueRangeMin
}

//******************************************************************************

- (void)setBlueRangeMax:(int)value {
    //TODO: setBlueRangeMax
}

//******************************************************************************

- (void)setAlphaRangeMin:(int)value {
    //TODO: setAlphaRangeMin
}

//******************************************************************************

- (void)setAlphaRangeMax:(int)value {
    //TODO: setAlphaRangeMax
}

//******************************************************************************

- (void)setPolygonsMin:(int)value {
    //TODO: setPolygonsMin
}

//******************************************************************************

- (void)setPolygonsMax:(int)value {
    //TODO: setPolygonsMax
}

//******************************************************************************

- (void)setPointsPerPolygonMin:(int)value {
    //TODO: setPointsPerPolygonMin
}

//******************************************************************************

- (void)setPointsPerPolygonMax:(int)value {
    if (value < pointsPerPolygonMin) {
        pointsPerPolygonMin = value;
    }
   
    pointsPerPolygonMax = value;
}

//******************************************************************************

- (void)setPointsMin:(int)value {
    if (value > pointsMax) {
        pointsMax = value;
    }
   
    pointsMin = value;
}

//******************************************************************************

- (void)setPointsMax:(int)value {
    if (value < pointsMin) {
        pointsMin = value;
    }
   
    pointsMax = value;
}

//******************************************************************************

- (void)setMovePointRangeMin:(int)value {
    if (value > movePointRangeMid) {
        movePointRangeMid = value;
    }
   
    movePointRangeMin = value;
}

//******************************************************************************

- (void)setMovePointRangeMid:(int)value {
    if (value < movePointRangeMin) {
        movePointRangeMin = value;
    }
   
    movePointRangeMid = value;
}

//******************************************************************************

- (void)activate {
    activeAddPolygonMutationRate = addPolygonMutationRate;
    activeRemovePolygonMutationRate = removePolygonMutationRate;
    activeMovePolygonMutationRate = movePolygonMutationRate;
   
    activeAddPointMutationRate = addPointMutationRate;
    activeRemovePointMutationRate = removePointMutationRate;
    activeMovePointMaxMutationRate = movePointMaxMutationRate;
    activeMovePointMidMutationRate = movePointMidMutationRate;
    activeMovePointMinMutationRate = movePointMinMutationRate;
   
    activeRedMutationRate = redMutationRate;
    activeGreenMutationRate = greenMutationRate;
    activeBlueMutationRate = blueMutationRate;
    activeAlphaMutationRate = alphaMutationRate;
   
    activeRedRangeMin = redRangeMin;
    activeRedRangeMax = redRangeMax;
    activeGreenRangeMin = greenRangeMin;
    activeGreenRangeMax = greenRangeMax;
    activeBlueRangeMin = blueRangeMin;
    activeBlueRangeMax = blueRangeMax;
    activeAlphaRangeMin = alphaRangeMin;
    activeAlphaRangeMax = alphaRangeMax;
   
    activePolygonsMax = polygonsMax;
    activePolygonsMin = polygonsMin;
   
    activePointsPerPolygonMax = pointsPerPolygonMax;
    activePointsPerPolygonMin = pointsPerPolygonMin;
   
    activePointsMax = pointsMax;
    activePointsMin = pointsMin;
   
    activeMovePointRangeMid = movePointRangeMid;
    activeMovePointRangeMin = movePointRangeMin;
}

//******************************************************************************

- (void)discard {
    addPolygonMutationRate = activeAddPolygonMutationRate;
    removePolygonMutationRate = activeRemovePolygonMutationRate;
    movePolygonMutationRate = activeMovePolygonMutationRate;

    addPointMutationRate = activeAddPointMutationRate;
    removePointMutationRate = activeRemovePointMutationRate;
    movePointMaxMutationRate = activeMovePointMaxMutationRate;
    movePointMidMutationRate = activeMovePointMidMutationRate;
    movePointMinMutationRate = activeMovePointMinMutationRate;

    redMutationRate = activeRedMutationRate;
    greenMutationRate = activeGreenMutationRate;
    blueMutationRate = activeBlueMutationRate;
    alphaMutationRate = activeAlphaMutationRate;

    //Limits / Constraints
    redRangeMin = activeRedRangeMin;
    redRangeMax = activeRedRangeMax;
    greenRangeMin = activeGreenRangeMin;
    greenRangeMax = activeGreenRangeMax;
    blueRangeMin = activeBlueRangeMin;
    blueRangeMax = activeBlueRangeMax;
    alphaRangeMin = activeAlphaRangeMin;
    alphaRangeMax = activeAlphaRangeMax;

    polygonsMax = activePolygonsMax;
    polygonsMin = activePolygonsMin;

    pointsPerPolygonMax = activePointsPerPolygonMax;
    pointsPerPolygonMin = activePointsPerPolygonMin;

    pointsMax = activePointsMax;
    pointsMin = activePointsMin;

    movePointRangeMid = activeMovePointRangeMid;
    movePointRangeMin = activeMovePointRangeMin;
}

//******************************************************************************

- (void)reset {
    activeAddPolygonMutationRate = 700;
    activeRemovePolygonMutationRate = 750;
    activeMovePolygonMutationRate = 700;

    activeAddPointMutationRate = 750;
    activeRemovePointMutationRate = 750;
    activeMovePointMaxMutationRate = 750;
    activeMovePointMidMutationRate = 750;
    activeMovePointMinMutationRate = 750;

    activeRedMutationRate = 750;
    activeGreenMutationRate = 750;
    activeBlueMutationRate = 750;
    activeAlphaMutationRate = 750;

    //Limits / Constraints
    activeRedRangeMin = MIN_COLOR_INTENSITY;
    activeRedRangeMax = MAX_COLOR_INTENSITY;
    activeGreenRangeMin = MIN_COLOR_INTENSITY;
    activeGreenRangeMax = MAX_COLOR_INTENSITY;
    activeBlueRangeMin = MIN_COLOR_INTENSITY;
    activeBlueRangeMax = MAX_COLOR_INTENSITY;
    activeAlphaRangeMin = MIN_ALPHA;
    activeAlphaRangeMax = MAX_ALPHA;

    activePolygonsMax = MAX_POLYGONS;
    activePolygonsMin = MIN_POLYGONS;

    activePointsPerPolygonMax = 3;
    activePointsPerPolygonMin = 3;

    activePointsMax = 2000;
    activePointsMin = 500;

    activeMovePointRangeMid = 20;
    activeMovePointRangeMin = 3;

    [self discard];
}

//******************************************************************************

@end
