//
//  SLBartView.m
//  BartO
//
//  Created by Raheel Ahmad on 5/14/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLBartView.h"
#import "SLPoint.h"

#define DEGREES_TO_RADIANS(x) ((x * 3.14) / 180)

const NSUInteger MAX_POINTS = 100;
const NSUInteger ELLIPSE_WIDTH = 2;
const CGFloat MIN_DISTANCE_FOR_HIT = 10;

@interface SLBartView ()

@property (nonatomic) NSMutableArray *allPoints;
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
		SLPoint *storedPoint = self.allPoints[index];
		CGFloat distance = distanceBetweenPoints(storedPoint.cgPoint, touchedPoint);
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

- (void)addPointToPath:(CGPoint)point pointType:(POINT_TYPE)point_type {
	SLPoint *newPoint = [[SLPoint alloc] init];
	newPoint.x = point.x;
	newPoint.y = point.y;
	newPoint.pointType = point_type;
	[self.allPoints addObject:newPoint];
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.drawing) {
		return;
	}
	CGPoint point = [self pointForTouches:touches];
	
	if (self.addingControlPoint) {
		[self addPointToPath:self.previousPoint pointType:REGULAR_POINT_TYPE];
		[self addPointToPath:self.controlPoint pointType:CONTROL_POINT_TYPE];
		[self addPointToPath:point pointType:REGULAR_POINT_TYPE];
		[self.bezierPath moveToPoint:self.previousPoint];
		[self.bezierPath addQuadCurveToPoint:point controlPoint:self.controlPoint];
	} else {
		[self addPointToPath:point pointType:REGULAR_POINT_TYPE];
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
		[self addPointToPath:point pointType:REGULAR_POINT_TYPE];
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

- (void)printPoints {
	int index = 0;
	while (index < self.pointsCount) {
		SLPoint *point = self.allPoints[index];
		NSLog(@"Point: %@", point);
		index++;
	}
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	if (!self.context)
		self.context = UIGraphicsGetCurrentContext();
	
	[self printPoints];
	
	CGContextSetRGBFillColor(self.context, 0.5f, 0.5f, 0.9f, 1.0f);
	CGContextFillRect(self.context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
	[[UIColor yellowColor] setFill];
	
	CGContextSetLineWidth(self.context, 2.0f);
	[[UIColor darkGrayColor] setStroke];
	UIBezierPath *path = [UIBezierPath bezierPath];
	for (int index = 1; index < self.allPoints.count; index++) {
		SLPoint *point = self.allPoints[index];
		if (point.pointType == CONTROL_POINT_TYPE) {
			if (index + 1 < self.allPoints.count) { // we can draw a bezier curve
				SLPoint *next = self.allPoints[index + 1];
				[path addQuadCurveToPoint:next.cgPoint controlPoint:point.cgPoint];
				index++; // move one more to move ahead of the next point at the end of this loop run
				CGContextFillEllipseInRect(self.context, CGRectMake(point.x - ELLIPSE_WIDTH/2, point.y - ELLIPSE_WIDTH/2, ELLIPSE_WIDTH, ELLIPSE_WIDTH));
			}
		} else {
			if (index == 1) {
				// then move to the first point
				SLPoint *previous = self.allPoints[0];
				[path moveToPoint:previous.cgPoint];
			}
			
			[path addLineToPoint:point.cgPoint];
		}
	}
	[path stroke];
	
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
		_allPoints = [[NSMutableArray alloc] initWithCapacity:20];
		_hitIndex = -1;
		_pointsCount = 0;
		_bezierPath = [UIBezierPath bezierPath];
	}
	return self;
}

@end
