//
//  EvoLisaAppDelegate.h
//  EvoLisa
//
//  Created by Paul Dardeau on 1/16/10.
//  Copyright 2010 Paul Dardeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EvoLisaWindowController;


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface EvoLisaAppDelegate : NSObject
#else
@interface EvoLisaAppDelegate : NSObject <NSApplicationDelegate>
#endif
{
   NSWindow *window;
   EvoLisaWindowController* windowController;
}

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet EvoLisaWindowController* windowController;

@end
