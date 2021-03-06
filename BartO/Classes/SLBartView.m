//
//  SLBartView.m
//  BartO
//
//  Created by Raheel Ahmad on 5/14/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLBartView.h"
#import "SLPoint.h"
#import "SLPath.h"

#define DEGREES_TO_RADIANS(x) ((x * 3.14) / 180)

@interface SLBartView ()

@property (nonatomic, readonly) SLPath *currentPath;
@property (nonatomic, strong) NSMutableArray *paths;

@property (nonatomic) SLPoint *previousPoint;
@property (nonatomic) SLPoint *controlPoint;
@property (nonatomic) SLPoint *movingPoint;
@property (nonatomic) SLPoint *hitPoint;

@property (nonatomic) BOOL touchHeldDown;

@property (nonatomic) CGContextRef context;

@end

@implementation SLBartView

#pragma mark - Properties

- (SLPath *)currentPath {
	return [self.paths lastObject];
}

#pragma mark - Public Interface

- (void)startNewPath {
	[self resetPathStates];
	SLPath *newPath = [[SLPath alloc] init];
	[self.paths addObject:newPath];
	[self setNeedsDisplay];
}

- (void)clear {
	[self.paths removeAllObjects];
	[self setNeedsDisplay];
}

- (void)undo {
	[self.undoManager undo];
	[self setNeedsDisplay];
}

- (void)toggleMarkers {
	[self.paths makeObjectsPerformSelector:@selector(toggleMarkers)];
	[self setNeedsDisplay];
}

- (void)resetPathStates {
	self.controlPoint = nil;
	self.touchHeldDown = NO;
	self.hitPoint = nil;
	self.movingPoint = nil;
	self.previousPoint = nil;
}

#pragma mark - Hit detection

- (void)detectHit:(CGPoint)touchedPoint {
	for (SLPath *path in self.paths) {
		SLPoint *hitPoint = [path detectHit:touchedPoint];
		if (hitPoint) {
			self.hitPoint = hitPoint;
			SLPoint *originalPoint = [SLPoint pointWithX:hitPoint.x y:hitPoint.y];
			[self.undoManager registerUndoWithTarget:hitPoint selector:@selector(moveToPoint:) object:originalPoint];
			break;
		}
	}
}

- (void)addPointToPath:(CGPoint)point pointType:(POINT_TYPE)point_type {
	[self.currentPath addPoint:point type:point_type];
	
	// only register undo for regular point types
	if (point_type == REGULAR_POINT_TYPE) {
		[self.undoManager registerUndoWithTarget:self.currentPath selector:@selector(undo) object:nil];
	}
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.currentPath) {
		return;
	}
	CGPoint point = [self pointForTouches:touches];
	
	if (self.hitPoint) {
		self.hitPoint.touched = NO;
		self.hitPoint = nil;
	} else {
		if (self.controlPoint) {
			[self addPointToPath:self.controlPoint.cgPoint pointType:CONTROL_POINT_TYPE];
			[self addPointToPath:point pointType:REGULAR_POINT_TYPE];
		} else {
			[self addPointToPath:point pointType:REGULAR_POINT_TYPE];
		}
		self.previousPoint = [SLPoint pointWithCGPoint:point];
	}
	
	self.touchHeldDown = NO;
	self.controlPoint = nil;
	
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.currentPath) {
		return;
	}
	
	CGPoint point = [self pointForTouches:touches];
	
	if (self.hitPoint) {
		self.hitPoint.x = point.x;
		self.hitPoint.y = point.y;
	} else if (self.touchHeldDown && !self.controlPoint) {
		self.controlPoint = [SLPoint pointWithCGPoint:point];
	}
	self.movingPoint = [SLPoint pointWithCGPoint:point];
	
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point = [self pointForTouches:touches];
	
	[self detectHit:point];
	
	if (self.hitPoint) {
		
	} else if (!self.currentPath) {
		SLPath *currentPath = [[SLPath alloc] init];
		[self.paths addObject:currentPath];
		self.previousPoint = [SLPoint pointWithCGPoint:point];
	}
	
	self.touchHeldDown = YES;
	[self setNeedsDisplay];
}

- (CGPoint)pointForTouches:(NSSet *)touches {
	UITouch *touch = [[touches allObjects] lastObject];
	return [touch locationInView:self];
}

- (void)printPoints {
	[self.currentPath printPoints];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	if (!self.context)
		self.context = UIGraphicsGetCurrentContext();
	
	//Background
	UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
	CGContextDrawImage(self.context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)), backgroundImage.CGImage);
	
	[[UIColor colorWithWhite:0.7f alpha:0.7f] setFill];
	for (SLPath *path in self.paths) {
		[path drawInContext:self.context];
	}
	
	// draw the curve for the currently drawing curve
	if (self.controlPoint) {
		[[UIColor lightGrayColor] setStroke];
		UIBezierPath *path = [UIBezierPath bezierPath];
		CGFloat pattern[] = {4.0f, 2.0f};
		[path setLineDash:pattern count:2 phase:2];
		
		[path moveToPoint:self.previousPoint.cgPoint];
		[path addQuadCurveToPoint:self.movingPoint.cgPoint controlPoint:self.controlPoint.cgPoint];
		[path stroke];
	}
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_paths = [NSMutableArray arrayWithCapacity:20];
	}
	return self;
}
@end
