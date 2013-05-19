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
@property (nonatomic) BOOL firstTouch;
@property (nonatomic) BOOL secondTouch;
@property (nonatomic) BOOL thirdTouch;

@property (nonatomic) CGPoint *allPoints;
@property (nonatomic) NSUInteger pointsCount;

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
	if (self.hitIndex >= 0) {
		[self setNeedsDisplay];
		self.hitIndex = -1;
		return;
	}
	CGPoint touchedPoint = [self pointForTouches:touches];
	
	if (!self.firstTouch) {
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount++] = touchedPoint;
		self.firstTouch = YES;
		self.secondTouch = NO;
		self.thirdTouch = NO;
	} else {
		self.firstTouch = NO;
	}
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	[self detectHit:touchedPoint];
	
	if (self.firstTouch) {
		self.secondTouch = YES;
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount++] = touchedPoint;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	if (self.hitIndex >= 0) {
		CGPoint *movingPoint = (self.allPoints + self.hitIndex);
		movingPoint->x = touchedPoint.x;
		movingPoint->y = touchedPoint.y;
	} else if (self.firstTouch && self.secondTouch) {
		if (!self.thirdTouch) {
			self.pointsCount++;
		}
		self.thirdTouch = YES;
		
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount - 1] = touchedPoint;
		
	}
	[self setNeedsDisplay];
}

- (CGPoint)pointForTouches:(NSSet *)touches {
	UITouch *touch = [[touches allObjects] lastObject];
	return [touch locationInView:self];
}

#pragma mark - Drawing

- (void)drawMarkerAtPoint:(CGPoint)point {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor whiteColor] setFill];
	CGContextFillEllipseInRect(context, CGRectMake(point.x - ELLIPSE_WIDTH * 1.5, point.y - ELLIPSE_WIDTH * 1.5, ELLIPSE_WIDTH * 3, ELLIPSE_WIDTH * 3));
	[[UIColor blueColor] setFill];
	CGContextFillEllipseInRect(context, CGRectMake(point.x - ELLIPSE_WIDTH, point.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
}

- (void)printPoints {
	int index = 0;
	while (index < self.pointsCount) {
		CGPoint point = self.allPoints[index];
		NSLog(@"Point: %@", NSStringFromCGPoint(point));
		index++;
	}
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat pattern[] = {2.0f, 2.0};
	
	CGContextSetRGBFillColor(context, 0.9f, 0.7f, 0.9f, 1.0f);
	CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
	
	CGContextSetLineWidth(context, 2.0f);
	[[UIColor darkGrayColor] setStroke];
	[[UIColor blueColor] setFill];
	CFIndex index = 0;
	while (index < self.pointsCount) {
		CGPoint first = self.allPoints[index++];
		[self drawMarkerAtPoint:first];
		if (index + 2 <= self.pointsCount) {
			UIBezierPath *path = [UIBezierPath bezierPath];
			CGPoint second = self.allPoints[index++];
			CGPoint third = self.allPoints[index++];
			[path moveToPoint:first];
			[path addQuadCurveToPoint:third controlPoint:second];
			[path stroke];
			
			[path setLineDash:pattern count:2 phase:2];
			[path moveToPoint:second];
			[path addLineToPoint:first];
			[path moveToPoint:second];
			[path addLineToPoint:third];
			[path stroke];
			
			[self drawMarkerAtPoint:second];
			[self drawMarkerAtPoint:third];
		} else {
			break;
		}
	}
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_allPoints = calloc(MAX_POINTS, sizeof(CGPoint));
		_hitIndex = -1;
	}
	return self;
}

@end
