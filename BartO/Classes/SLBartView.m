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
	if (self.firstTouch) {
		self.secondTouch = YES;
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount++] = touchedPoint;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchedPoint = [self pointForTouches:touches];
	if (self.firstTouch && self.secondTouch) {
		if (!self.thirdTouch) {
			self.pointsCount++;
		}
		self.thirdTouch = YES;
		
		CGPoint *pointer = self.allPoints;
		pointer[self.pointsCount - 1] = touchedPoint;
		
		[self setNeedsDisplay];
	}
}

- (CGPoint)pointForTouches:(NSSet *)touches {
	UITouch *touch = [[touches allObjects] lastObject];
	return [touch locationInView:self];
}

#pragma mark - Drawing

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
		CGContextFillEllipseInRect(context, CGRectMake(first.x - ELLIPSE_WIDTH, first.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
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
			
			CGContextFillEllipseInRect(context, CGRectMake(second.x - ELLIPSE_WIDTH, second.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
			CGContextFillEllipseInRect(context, CGRectMake(third.x - ELLIPSE_WIDTH, third.y - ELLIPSE_WIDTH, ELLIPSE_WIDTH * 2, ELLIPSE_WIDTH * 2));
		} else {
			break;
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
