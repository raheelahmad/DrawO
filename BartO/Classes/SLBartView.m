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
const NSUInteger ELLIPSE_WIDTH = 4;

@interface SLBartView ()
@property (nonatomic) BOOL firstTouch;
@property (nonatomic) BOOL secondTouch;
@property (nonatomic) BOOL thirdTouch;
@property (nonatomic) CGPoint *allPoints;
@property (nonatomic) NSUInteger pointsCount;
@end

@implementation SLBartView

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	
	if (!self.firstTouch) {
		CGPoint *pointer = self.allPoints;
		if (self.pointsCount > 0) {
			self.pointsCount++;
		}
		pointer[self.pointsCount++] = touchedPoint;
		self.firstTouch = YES;
		self.secondTouch = NO;
		self.thirdTouch = NO;
	} else {
		self.firstTouch = NO;
	}
//	[self setNeedsDisplay]
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	if (self.firstTouch) {
		self.secondTouch = YES;
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount++] = touchedPoint;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	if (self.firstTouch && self.secondTouch) {
		self.thirdTouch = YES;
		
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount] = touchedPoint;
		
		[self setNeedsDisplay];
	}
}

- (CGPoint)pointForTouches:(NSSet *)touches {
	UITouch *touch = [[touches allObjects] lastObject];
	return [touch locationInView:self];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(myContext, 0.9f, 0.7f, 0.9f, 1.0f);
	CGContextFillRect(myContext, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
	
	CGContextSetLineWidth(myContext, 2.0f);
	[[UIColor darkGrayColor] setStroke];
	[[UIColor blueColor] setFill];
	CFIndex index = 0;
	while (index < self.pointsCount) {
		if (index < self.pointsCount) {
			CGPoint first = self.allPoints[index];
			CGContextFillEllipseInRect(myContext, CGRectMake(first.x - ELLIPSE_WIDTH, first.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
		}
		
		if (index + 2 <= self.pointsCount) {
			UIBezierPath *path = [UIBezierPath bezierPath];
			CGPoint first = self.allPoints[index++];
			CGPoint second = self.allPoints[index++];
			CGPoint third = self.allPoints[index++];
			[path moveToPoint:first];
			[path addQuadCurveToPoint:third controlPoint:second];
			[path stroke];
		}
	}
	
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.allPoints = calloc(MAX_POINTS, sizeof(CGPoint));
	}
	return self;
}

@end
