//
//  MainWindow.m
//  osx-gl-0001
//
//  Created by anti on 14.04.20.
//  Copyright © 2020 anti666. All rights reserved.
//

#import "MainWindow.h"

#import "OpenGLView.h"

@interface MainWindow ()

// I always mess that up!
// properties belong into the interface!

@property OpenGLView* openGLView;

@end

@implementation MainWindow


- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {

	if( self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag] )
	{
		self.openGLView = [OpenGLView alloc];
		// init here	// maybe overkill
		NSRect frame = self.frame; // bounds?
		self.openGLView = [self.openGLView initWithFrame:frame pixelFormat:[OpenGLView defaultPixelFormat]];
		[self setContentView:self.openGLView];	// view is empty, so we see invisble window instead of green ... good :)
	}
	
	return self;
}


@end

