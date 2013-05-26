//
//  SLPoint.m
//  BartO
//
//  Created by Raheel Ahmad on 5/21/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPoint.h"

@implementation SLPoint

+ (SLPoint *)pointWithX:(CGFloat)x y:(CGFloat)y {
	SLPoint *point = [[SLPoint alloc] init];
	point.x = x;
	point.y = y;
	
	return point;
}

+ (SLPoint *)pointWithCGPoint:(CGPoint)cgPoint {
	return [self pointWithX:cgPoint.x y:cgPoint.y];
}

- (void)moveToPoint:(SLPoint *)point {
	self.x = point.x;
	self.y = point.y;
}

- (CGPoint)cgPoint {
	return CGPointMake(self.x, self.y);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"{%f, %f}", self.x, self.y];
}

@end
