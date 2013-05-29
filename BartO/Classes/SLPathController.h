//
//  SLPathController.h
//  BartO
//
//  Created by Raheel Ahmad on 5/28/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLPath, SLPoint;
@interface SLPathController : NSObject
- (void)touchEndedAtPoint:(SLPoint *)point;
- (void)touchBeganAtPoint:(SLPoint *)point;
- (void)toucheMovedToPoint:(SLPoint *)point;

@property (nonatomic, readonly) NSArray *paths;
@end
