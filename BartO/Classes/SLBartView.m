//
//  SLBartView.m
//  BartO
//
//  Created by Raheel Ahmad on 5/14/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLBartView.h"

#define DEGREES_TO_RADIANS(x) ((x * 3.14) / 180)

const NSUInteger MAX_POINTS = 100;
const NSUInteger ELLIPSE_WIDTH = 2;
const CGFloat MIN_DISTANCE_FOR_HIT = 10;

@interface SLBartView ()

@property (nonatomic) CGPoint *allPoints;
@property (nonatomic) NSUInteger pointsCount;

@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) CGPoint controlPoint;
@property (nonatomic) CGPoint movingPoint;

@property (nonatomic) BOOL addingControlPoint;
@property (nonatomic) BOOL drawing;
@property (nonatomic) BOOL touchHeldDown;

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic) CGContextRef context;

@property (nonatomic) NSInteger hitIndex;
@end

@implementation SLBartView

#pragma mark - Hit detection

- (void)detectHit:(CGPoint)touchedPoint {
	NSUInteger index = 0;
	
	BOOL hit = NO;
	while (index < self.pointsCount) {
		CGPoint storedPoint = self.allPoints[index];
		CGFloat distance = distanceBetweenPoints(storedPoint, touchedPoint);
		if (distance <= MIN_DISTANCE_FOR_HIT) {
			self.hitIndex = index;
			hit = YES;
			break;
		}
		index++;
	}
	
	if (!hit)
		self.hitIndex = -1;
	
}

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) {
	CGFloat delta_x = p1.x - p2.x;
	CGFloat delta_y = p1.y - p2.y;
	
	return sqrtf(delta_x * delta_x + delta_y * delta_y);
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.drawing) {
		return;
	}
	CGPoint point = [self pointForTouches:touches];
	
	if (self.addingControlPoint) {
		[self.bezierPath moveToPoint:self.previousPoint];
		[self.bezierPath addQuadCurveToPoint:point controlPoint:self.controlPoint];
	} else {
		[self.bezierPath addLineToPoint:point];
	}
	self.previousPoint = point;
	
	self.touchHeldDown = NO;
	self.addingControlPoint = NO;
	
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.drawing) {
		return;
	}
	
	CGPoint point = [self pointForTouches:touches];
	if (self.touchHeldDown && !self.addingControlPoint) {
		self.controlPoint = point;
		self.addingControlPoint = YES;
	}
	self.movingPoint = point;
	
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point = [self pointForTouches:touches];
	if (!self.drawing) {
		[self.bezierPath moveToPoint:point];
		self.drawing = YES;
		self.previousPoint = point;
	}
	
	self.touchHeldDown = YES;
	[self setNeedsDisplay];
}

- (CGPoint)pointForTouches:(NSSet *)touches {
	UITouch *touch = [[touches allObjects] lastObject];
	return [touch locationInView:self];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	if (!self.context)
		self.context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(self.context, 0.9f, 0.7f, 0.9f, 1.0f);
	CGContextFillRect(self.context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
	
	CGContextSetLineWidth(self.context, 1.0f);
	[[UIColor darkGrayColor] setStroke];
	[self.bezierPath stroke];
	
	if (self.addingControlPoint) {
		[[UIColor lightGrayColor] setStroke];
		UIBezierPath *path = [UIBezierPath bezierPath];
		CGFloat pattern[] = {2.0f, 2.0f};
		[path setLineDash:pattern count:2 phase:2];
		
		[path moveToPoint:self.previousPoint];
		[path addQuadCurveToPoint:self.movingPoint controlPoint:self.controlPoint];
		[path stroke];
	}
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_allPoints = calloc(MAX_POINTS, sizeof(CGPoint));
		_hitIndex = -1;
		_bezierPath = [UIBezierPath bezierPath];
	}
	return self;
}

@end
