//
//  EvoLisaAppDelegate.m
//  EvoLisa
//
//  Created by Paul Dardeau on 1/16/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//
#include <sys/resource.h>

#import "EvoLisaAppDelegate.h"

@implementation EvoLisaAppDelegate

@synthesize window;
@synthesize windowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   
   // drop our priority to a "nice" value of 10
    /*
   const int rc = setpriority(PRIO_PROCESS, 0, 10);
   
   if (rc == 0) {
      NSLog(@"EvoLisa dropped priority, nice setting increased");
   } else {
      NSLog(@"EvoLisa: error -- unable to drop priority");
   }
     */
}

- (void)applicationWillTerminate:(NSNotification*)notification {
}

@end
