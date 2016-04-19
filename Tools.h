//
//  Tools.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/17/10.
//  Copyright 2010 SwampBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Tools : NSObject
{
}

+ (Tools*)instance;
+ (void)killInstance;

- (int)getRandomNumberWithMin:(int)minimum andMaximum:(int)maximum;
- (BOOL)willMutate:(int)mutationRate;
- (void)reseedRandomLibrary;
- (BOOL)randomBoolean;

@end
