//
//  Tools.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//
#include <stdlib.h>
#import "Tools.h"


static Tools* toolsInstance = nil;


@implementation Tools

//******************************************************************************

+ (Tools*)instance {
   if (toolsInstance == nil) {
      toolsInstance = [[Tools alloc] init];
   }
   
   return toolsInstance;
}

//******************************************************************************

+ (void)killInstance {
   [toolsInstance release];
   toolsInstance = nil;
}

//******************************************************************************

- (id)init {
   if ((self = [super init]) != nil) {
       [self reseedRandomLibrary];
   }
   
   return self;
}

//******************************************************************************

- (void)reseedRandomLibrary {
   srandom((unsigned int)time(NULL));
}

//******************************************************************************

- (int)getRandomNumberWithMin:(int)minimum andMaximum:(int)maximum {
   return (minimum + (maximum * (random() / (float) RAND_MAX)));
}

//******************************************************************************

- (BOOL)willMutate:(int)mutationRate {
    return 1 == [self getRandomNumberWithMin:0 andMaximum:mutationRate];
}

//******************************************************************************

- (BOOL)randomBoolean {
    return [self getRandomNumberWithMin:0 andMaximum:100] < 50;
}

//******************************************************************************

@end
