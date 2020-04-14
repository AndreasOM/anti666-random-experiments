//
//  main.m
//  osx-gl-0001
//
//  Created by anti on 14.04.20.
//  Copyright © 2020 anti666. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSApplication* app = [NSApplication sharedApplication];
		AppDelegate* appDelegate = [[AppDelegate alloc] init];
		[app setDelegate:appDelegate];
		[app run];
	}
//	return NSApplicationMain(argc, argv);	// this trys to load the nib/xib ;)
	return EXIT_SUCCESS;
}
