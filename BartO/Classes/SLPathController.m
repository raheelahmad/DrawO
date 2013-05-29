//
//  SLPathController.m
//  BartO
//
//  Created by Raheel Ahmad on 5/28/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLPathController.h"
#import "SLPoint.h"
#import "SLPath.h"

@interface SLPathController ()
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, readonly) SLPath *currentPath;
@end

@implementation SLPathController

#pragma mark - Touch interface

- (void)touchBeganAtPoint:(SLPoint *)point {
	
}

- (void)toucheMovedToPoint:(SLPoint *)point {
	
}

- (void)touchEndedAtPoint:(SLPoint *)point {
	
}

#pragma mark - Paths

- (SLPath *)currentPath {
	if ([self.paths count] < 1) {
		return nil;
	} else {
		return [self.paths lastObject];
	}
}

#pragma mark - NSObject

- (id)init {
	self = [super init];
	if (self) {
		_paths = [NSMutableArray arrayWithCapacity:10];
	}
	
	return self;
}
@end
