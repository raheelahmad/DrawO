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
const NSUInteger ELLIPSE_WIDTH = 16;

@interface SLPath ()
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic) BOOL showMarkers;
@end

@implementation SLPath

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) {
	CGFloat delta_x = p1.x - p2.x;
	CGFloat delta_y = p1.y - p2.y;
	
	return sqrtf(delta_x * delta_x + delta_y * delta_y);
}

- (void)toggleMarkers {
	self.showMarkers = !self.showMarkers;
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

- (void)drawMarkerAtPoint:(SLPoint *)point width:(CGFloat)width context:(CGContextRef)context {
	if (point.touched) {
		CGContextSaveGState(context);
		[[UIColor colorWithWhite:0.3f alpha:0.6f] setFill];
		CGContextFillEllipseInRect(context, CGRectMake(point.x - width, point.y - width, width * 2, width * 2));
		CGContextRestoreGState(context);
	}
	[UIColor colorWithWhite:0.3f alpha:0.9f];
	CGContextFillEllipseInRect(context, CGRectMake(point.x - width/2, point.y - width/2, width, width));
}

- (void)drawMarkersInContext:(CGContextRef)context {
	NSParameterAssert(self.points.count > 0);
	
	[self drawMarkerAtPoint:self.points[0] width:ELLIPSE_WIDTH/2 context:context];
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	path.lineWidth = 1.0f;
	CGFloat pattern[] = {4.0f, 2.0f};
	[path setLineDash:pattern count:2 phase:2];
	[[UIColor colorWithWhite:0.4f alpha:0.8f] setStroke];
	for (int index = 1; index < self.points.count; index++) {
		SLPoint *point = self.points[index];
		if (point.pointType == CONTROL_POINT_TYPE && index + 1 < self.points.count) {
			SLPoint *previous = self.points[index - 1];
			SLPoint *next = self.points[index + 1];
			[self drawMarkerAtPoint:point width:ELLIPSE_WIDTH context:context];
			[path moveToPoint:previous.cgPoint];
			[path addLineToPoint:point.cgPoint];
			[path addLineToPoint:next.cgPoint];
		}
		[self drawMarkerAtPoint:point width:ELLIPSE_WIDTH / 2 context:context];
	}
	[path stroke];
	
}

- (void)drawInContext:(CGContextRef)context {
	if (self.points.count < 1) {
		return; // nothing to draw
	}
	
	// Draw the path
	UIBezierPath *path = [UIBezierPath bezierPath];
	path.lineWidth = 2.0f;
	[[UIColor darkGrayColor] setStroke];
	SLPoint *previous = self.points[0];
	[path moveToPoint:previous.cgPoint];
	for (int index = 1; index < self.points.count; index++) {
		SLPoint *point = self.points[index];
		if (point.pointType == CONTROL_POINT_TYPE) {
			if (index + 1 < self.points.count) { // we can draw a bezier curve
				SLPoint *next = self.points[index + 1];
				[path addQuadCurveToPoint:next.cgPoint controlPoint:point.cgPoint];
				index++; // move one more to move ahead of the next point at the end of this loop run
			}
		} else {
			[path addLineToPoint:point.cgPoint];
		}
	}
	[path stroke];
	
	// draw the guide lines (for curve tangents)
	if (self.showMarkers) {
		[self drawMarkersInContext:context];
	}
	
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
		_showMarkers = YES;
	}
	return self;
}
@end
