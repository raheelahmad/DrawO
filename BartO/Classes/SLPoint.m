//
//  SLPoint.m
//  BartO
//
//  Created by Raheel Ahmad on 5/21/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPoint.h"

@implementation SLPoint

- (CGPoint)cgPoint {
	return CGPointMake(self.x, self.y);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"{%f, %f}", self.x, self.y];
}

@end
