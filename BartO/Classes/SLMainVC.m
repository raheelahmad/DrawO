//
//  SLMainVC.m
//  BartO
//
//  Created by Raheel Ahmad on 5/14/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLMainVC.h"
#import "SLBartView.h"

@interface SLMainVC ()

@end

@implementation SLMainVC

#pragma - mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
	[super loadView];
	
	SLBartView *bartView = [[SLBartView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:bartView];
	
	UIButton *trashButton = [self addButtonForImageName:@"trash.png" origin:CGPointMake(20, 20)];
	[trashButton addTarget:bartView action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *undoButton = [self addButtonForImageName:@"undo.png" origin:CGPointMake(60, 20)];
	[undoButton addTarget:bartView action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *startNewButton = [self addButtonForImageName:@"new_path.png" origin:CGPointMake(100, 20)];
	[startNewButton addTarget:bartView action:@selector(startNewPath) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)addButtonForImageName:(NSString *)imageName origin:(CGPoint)origin {
	UIImage *image = [UIImage imageNamed:imageName];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];
	button.frame = CGRectMake(origin.x, origin.y, image.size.width, image.size.height);
	[self.view addSubview:button];
	return button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
