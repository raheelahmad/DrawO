//
//  SLPath.m
//  BartO
//
//  Created by Raheel Ahmad on 5/22/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPath.h"

const NSUInteger MAX_POINTS = 100;
const CGFloat MIN_DISTANCE_FOR_HIT = 20;
const NSUInteger ELLIPSE_WIDTH = 8;

@interface SLPath ()
@property (nonatomic, strong) NSMutableArray *points;
@end

@implementation SLPath

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) {
	CGFloat delta_x = p1.x - p2.x;
	CGFloat delta_y = p1.y - p2.y;
	
	return sqrtf(delta_x * delta_x + delta_y * delta_y);
}

- (void)undo {
	SLPoint *lastPoint = [self.points lastObject];
	if (!lastPoint) {
		return;
	}
	
	// we can only remove regular points from the end
	if (lastPoint.pointType != REGULAR_POINT_TYPE) {
		return;
	}
	
	// remove the 2nd last point if it's a control point
	SLPoint *secondLastPoint = [self.points count] > 1 ? self.points[self.points.count - 2] : nil;
	if (secondLastPoint && secondLastPoint.pointType == CONTROL_POINT_TYPE) {
		[self.points removeObject:secondLastPoint];
	}
	
	[self.points removeObject:lastPoint];
}

- (void)clear {
	[self.points removeAllObjects];
}

- (void)addPoint:(CGPoint)point type:(POINT_TYPE)pointType {
	SLPoint *newPoint = [SLPoint pointWithCGPoint:point];
	newPoint.pointType = pointType;
	[self.points addObject:newPoint];
}

- (SLPoint *)detectHit:(CGPoint)touchedPoint {
	SLPoint *hitPoint;
	for (SLPoint *storedPoint in self.points) {
		CGFloat distance = distanceBetweenPoints(storedPoint.cgPoint, touchedPoint);
		if (distance <= MIN_DISTANCE_FOR_HIT) {
			hitPoint = storedPoint;
			hitPoint.touched = YES;
			break;
		}
	}
	return hitPoint;
}

- (void)drawMarkerAtPoint:(SLPoint *)point context:(CGContextRef)context {
	if (point.touched) {
		[[UIColor colorWithWhite:0.3f alpha:0.3f] setFill];
		CGContextFillEllipseInRect(context, CGRectMake(point.x - ELLIPSE_WIDTH, point.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
		
	}
	[UIColor colorWithWhite:0.7f alpha:0.7f];
	CGContextFillEllipseInRect(context, CGRectMake(point.x - ELLIPSE_WIDTH/2, point.y - ELLIPSE_WIDTH/2, ELLIPSE_WIDTH, ELLIPSE_WIDTH));
}

- (void)drawInContext:(CGContextRef)context {
	UIBezierPath *path = [UIBezierPath bezierPath];
	path.lineWidth = 1.0f;
	[[UIColor lightGrayColor] setStroke];
	for (int index = 1; index < self.points.count; index++) {
		SLPoint *point = self.points[index];
		if (point.pointType == CONTROL_POINT_TYPE && index + 1 < self.points.count) {
			SLPoint *previous = self.points[index - 1];
			SLPoint *next = self.points[index + 1];
			[self drawMarkerAtPoint:point context:context];
			[path moveToPoint:previous.cgPoint];
			[path addLineToPoint:point.cgPoint];
			[path addLineToPoint:next.cgPoint];
		}
	}
	[path stroke];
	
	path = [UIBezierPath bezierPath];
	path.lineWidth = 2.0f;
	// Draw the main path
	for (int index = 1; index < self.points.count; index++) {
		SLPoint *point = self.points[index];
		if (point.pointType == CONTROL_POINT_TYPE) {
			if (index + 1 < self.points.count) { // we can draw a bezier curve
				SLPoint *next = self.points[index + 1];
				[path addQuadCurveToPoint:next.cgPoint controlPoint:point.cgPoint];
				index++; // move one more to move ahead of the next point at the end of this loop run
			}
		} else {
			if (index == 1) {
				// then move to the first point
				SLPoint *previous = self.points[0];
				[path moveToPoint:previous.cgPoint];
			}
			
			[path addLineToPoint:point.cgPoint];
		}
	}
	[path stroke];
}

- (void)printPoints {
	for (SLPoint *point in self.points) {
		NSLog(@"Point: %@", point);
	}
}

- (id)init {
	self = [super init];
	if (self) {
		_points = [NSMutableArray arrayWithCapacity:10];
	}
	return self;
}
@end
