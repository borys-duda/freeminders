//
//  FrostedViewController.m
//  Stadium Guide
//
//  Created by Spencer Morris on 12/12/13.
//  Copyright (c) 2013 Scalpr. All rights reserved.
//

#import "FrostedViewController.h"
#import "AppDelegate.h"

@interface FrostedViewController ()

@end

@implementation FrostedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
