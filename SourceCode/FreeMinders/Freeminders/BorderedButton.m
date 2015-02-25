//
//  TSBorderedButton.m
//  Spencer Morris
//
//  Created by Spencer Morris on 1/11/14.
//  Copyright (c) 2014 Spencer Morris All rights reserved.
//

#import "BorderedButton.h"
#import "Const.h"

@implementation BorderedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)didMoveToWindow
{
    if (IOS_VERSION_NEWER_OR_EQUAL_TO(@"7.0")) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [self.tintColor CGColor];
        self.layer.cornerRadius = 10;
    }
}

@end
