//
//  OpenGLView.m
//  osx-gl-0001
//
//  Created by anti on 14.04.20.
//  Copyright © 2020 anti666. All rights reserved.
//

#import "OpenGLView.h"

#include <OpenGL/gl3.h>

@interface OpenGLView ()
@property CVDisplayLinkRef displayLink;
@end

@implementation OpenGLView
GLuint vbo = 0;
GLuint vao = 0;
GLuint vs = 0;
GLuint fs = 0;
GLuint pipeline = 0;

+ (NSOpenGLPixelFormat *)defaultPixelFormat {
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAStencilSize, 8,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFAColorFloat,
		NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion4_1Core,
		NSOpenGLPFAClosestPolicy,
		0	// end marker
	};
	NSOpenGLPixelFormat* pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	return pf;
}

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	// for debugging
	if( self = [super initWithFrame:frameRect pixelFormat:format] ) {
		
	}
	
	return self;
}

- (void)prepareOpenGL {
	[super prepareOpenGL];	// ;)
	[self initRendering];
	// ugly? maybe, but pretty much boiler plate...
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);

	CVDisplayLinkSetOutputHandler(_displayLink, ^CVReturn(CVDisplayLinkRef  _Nonnull displayLink, const CVTimeStamp * _Nonnull inNow, const CVTimeStamp * _Nonnull inOutputTime, CVOptionFlags flagsIn, CVOptionFlags * _Nonnull flagsOut) {
		// better
		// run update, render here ... later
		return [self getFrameForTime:inNow];
	});
	
	// oops, need to link the openglcontext!
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
	CVDisplayLinkStart(_displayLink);
	
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)time {
//	NSLog(@"getFrameForTime");
	NSOpenGLContext* ctx = self.openGLContext;
	[ctx makeCurrentContext];
	CGLLockContext( [ctx CGLContextObj] );
	
	NSTimeInterval timeStep = 1.0 / ( time->rateScalar *(double)time->videoTimeScale/(double)time->videoRefreshPeriod);
	[self updateAndRender:timeStep];
	
	// do not flushBuffer on the context here!
	CGLUnlockContext([ctx CGLContextObj]);
	CGLFlushDrawable([ctx CGLContextObj]);
	return kCVReturnSuccess;
}

static GLfloat s_vertices[] = {
	-1.0f,  1.0f+2.0f, 0.0f,	// left top	(2x!)
	-1.0f, -1.0f, 0.0f,	// left bottom
	1.0f+2.0f, -1.0f, 0.0f,	// right bottom (2x!)
};

- (void)initRendering {
	glGenBuffers( 1, &vbo );
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, 9*sizeof(GLfloat), s_vertices, GL_STATIC_DRAW);
	
	glGenVertexArrays(1, &vao);
	glBindVertexArray( vao );
	glEnableVertexAttribArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);	// yes duplicate from above, but might do this somewhere else
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	
	// shaders
	// NEVER EVER put your shader code into your source code!
	const char* vsCode =
	"#version 410\n"
	"\n"
	"in vec3 p;\n"
	"out vec2 TexCoord;\n"
	"void main()\n"
	"{\n"
	"	TexCoord = p.xy;\n"
	"	gl_Position = vec4( p, 1.0 );\n"
	"}\n";
	
	const char* fsCode =
	"#version 410\n"
	"\n"
	"in vec2 TexCoord;\n"
	"out vec4 frag_color;\n"
	"void main()\n"
	"{\n"
	"	vec2 p = TexCoord*vec2( 16./9.0, 1.0 );\n"
	"	float l = length( p );\n"
	"	float blue = smoothstep( 0.49, 0.51, sin(l) );\n"
	"	frag_color = vec4( TexCoord.x, TexCoord.y, blue, 1.0 );\n"
	"}\n";

	GLint rc = 0;

	vs = glCreateShader( GL_VERTEX_SHADER );
	glShaderSource( vs, 1, &vsCode, NULL);
	glCompileShader( vs );
	glGetShaderiv( vs, GL_COMPILE_STATUS, &rc );
	NSLog(@"fs GL_COMPILE_STATUS: %d", rc);
	if( rc != GL_TRUE )
	{
		char buffer[ 1024 ] = { 0 };
		glGetShaderInfoLog( vs, sizeof( buffer ), NULL, buffer);
		NSLog(@"glCompileShader (vs) failed\n%s", buffer);
		NSLog(@"For shader:\n%s", vsCode );
	}
	[self checkGlError];
	
	fs = glCreateShader( GL_FRAGMENT_SHADER );
	glShaderSource( fs, 1, &fsCode, NULL);
	glCompileShader( fs );
	glGetShaderiv( fs, GL_COMPILE_STATUS, &rc );
	NSLog(@"fs GL_COMPILE_STATUS: %d", rc);
	if( rc != GL_TRUE )
	{
		char buffer[ 1024 ] = { 0 };
		glGetShaderInfoLog( fs, sizeof( buffer ), NULL, buffer);
		NSLog(@"glCompileShader (fs) failed\n%s", buffer);
		NSLog(@"For shader:\n%s", fsCode );
	}
	[self checkGlError];
	
	pipeline = glCreateProgram();
	glAttachShader( pipeline, vs );
	glAttachShader( pipeline, fs );
	glLinkProgram( pipeline );
	glGetProgramiv( pipeline, GL_LINK_STATUS, &rc );
	NSLog(@"GL_LINK_STATUS: %d", rc);
	if( rc != GL_TRUE )
	{
		NSLog(@"glLinkProgram failed");
	}
	[self checkGlError];
}

- (void)checkGlError {
	GLenum error = glGetError();
	if( error != GL_NO_ERROR )
	{
		switch( error )
		{
			case GL_INVALID_OPERATION:
				NSLog(@"gl error: GL_INVALID_OPERATION %d", error);
				break;
			default:
				NSLog(@"gl error: %d", error);
				break;
		}
	}
}

- (void)updateAndRender:(double)timeStep {
	static float totalTime = 0.0f;
	totalTime += timeStep;
	float red = 0.5f+0.5f*sinf( totalTime );
	// redraw based on timer here :)
	glClearColor( red, 0.2f, 0.2f, 1.0f );
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

//	[self checkGlError];
//	glDisable(GL_DEPTH_TEST);
//	glDisable(GL_CULL_FACE);
//	[self checkGlError];
	glUseProgram( pipeline );
//	[self checkGlError];
	glBindVertexArray( vao );
//	[self checkGlError];
	glDrawArrays(GL_TRIANGLES, 0, 3);
//	[self checkGlError];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
	
	// called once :(
}

@end
