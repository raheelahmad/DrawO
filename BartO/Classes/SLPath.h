//
//  SLPath.h
//  BartO
//
//  Created by Raheel Ahmad on 5/22/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLPoint.h"

@class SLPoint;
@interface SLPath : NSObject

- (void)undo;
- (void)clear;
- (SLPoint *)detectHit:(CGPoint)touchedPoint;
- (void)addPoint:(CGPoint)point type:(POINT_TYPE)pointType;

- (void)printPoints;
- (void) drawInContext:(CGContextRef)context;

@end
