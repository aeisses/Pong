//
//  BallImageView.m
//  Pong
//
//  Created by Aaron Eisses on 2014-06-21.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import "BallView.h"

@implementation BallView

#pragma Overide Methods
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma Public Methods
- (void)update
{
    if (CGRectIntersectsRect(self.frame, _paddle1.frame) || CGRectIntersectsRect(self.frame, _paddle2.frame))
    {
        _speedY = [NSNumber numberWithFloat:([_speedY floatValue] * -1 * ((arc4random_uniform(1000)/1000) + 1))];
    }
    if (self.frame.origin.x < 20)
    {
        _speedX = [NSNumber numberWithFloat:([_speedX floatValue] * -1)];
    }
    if (self.frame.origin.x > (300 - self.frame.size.width))
    {
        _speedX = [NSNumber numberWithFloat:([_speedX floatValue] * -1)];
    }
    self.center = (CGPoint){self.center.x+[_speedX floatValue],self.center.y+[_speedY floatValue]};
}

@end
