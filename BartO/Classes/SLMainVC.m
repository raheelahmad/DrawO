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
