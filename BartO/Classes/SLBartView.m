//
//  SLBartView.m
//  BartO
//
//  Created by Raheel Ahmad on 5/14/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLBartView.h"

#define DEGREES_TO_RADIANS(x) ((x * 3.14) / 180)

@implementation SLBartView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Touched: %@", touches);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(myContext, 0.7f, 0.7f, 0.7f, 1.0f);
	CGContextFillRect(myContext, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path addArcWithCenter:CGPointMake(200, 200) radius:60 startAngle:0 endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
	[path addCurveToPoint:CGPointMake(300, 100) controlPoint1:CGPointMake(250, 60) controlPoint2:CGPointMake(260, 210)];
	
	CGContextSaveGState(myContext);
	
	CGContextTranslateCTM(myContext, -20, 100);
	[path stroke];
	CGContextTranslateCTM(myContext, 0, 40);
	[[UIColor greenColor] setStroke];
	[path stroke];
	
	CGContextRestoreGState(myContext);
	
    CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);// 3
    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));// 4
    CGContextSetRGBFillColor (myContext, 0, 0, 1, .5);// 5
    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));
}

@end
