//
//  AppDelegate.m
//  osx-gl-0001
//
//  Created by anti on 14.04.20.
//  Copyright © 2020 anti666. All rights reserved.
//

#import "AppDelegate.h"

#import "MainWindow.h"
@interface AppDelegate ()

@property MainWindow *mainWindow;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	NSScreen* screen = nil;
	for( NSScreen* s in [NSScreen screens] )
	{
		// :TODO: pick "current" screen
		NSRect f = [s frame];
		if( f.size.width == 1920 )	// :HACK: my other screen is bigger ;)
		{
			screen = s;
		}
	}
	NSRect frame = [screen frame];
	frame.size.width *= 0.5f;	// just make it smaller for now
	frame.size.height *= 0.5f;
	
	NSWindowStyleMask mask = NSWindowStyleMaskBorderless;
	
	self.mainWindow = [[MainWindow alloc]
				  initWithContentRect:frame
				  styleMask:mask
				  backing:NSBackingStoreBuffered
				  defer:NO
				];
	
	[self.mainWindow setLevel:NSFloatingWindowLevel];
	[self.mainWindow center]; // ??? maybe not?
	[self.mainWindow setBackgroundColor:[NSColor colorWithCalibratedRed:0.2 green:0.4 blue:0.2 alpha:1.0]]; // grey is to boring

	// :TODO: add view ;)
	
	[self.mainWindow makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
