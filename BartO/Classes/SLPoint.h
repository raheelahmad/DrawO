//
//  SLPoint.h
//  BartO
//
//  Created by Raheel Ahmad on 5/21/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	REGULAR_POINT_TYPE,
	CONTROL_POINT_TYPE
} POINT_TYPE;

@interface SLPoint : NSObject
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) POINT_TYPE pointType;
@property (nonatomic) BOOL touched;
@property (nonatomic, readonly) CGPoint cgPoint;
@end
