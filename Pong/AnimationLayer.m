//
//  MainViewBackGroundLayer.m
//  Marisa
//
//  Created by Aaron Eisses on 12-11-09.
//  Copyright (c) 2012 Aaron Eisses. All rights reserved.
//

#import "AnimationLayer.h"

@implementation AnimationLayer

@synthesize myDelegate;

#pragma Overide Methods
+ (BOOL)needsDisplayForKey:(NSString *)key;
{
    return [key isEqualToString:@"timerIndex"];
}

+ (id < CAAction >)defaultActionForKey:(NSString *)aKey;
{
    if ([aKey isEqualToString:@"contentsRect"] || [aKey isEqualToString:@"position"] || [aKey isEqualToString:@"bounds"])
        return (id < CAAction >)[NSNull null];
    
    return [super defaultActionForKey:aKey];
}

-(void)display
{
    [myDelegate updateDisplay];
}

#pragma Public Methods
-(id)initWithFile:(NSString *)fileName andFrame:(CGRect)frame;
{
    if (self = [super init]) {
        NSString *imageString = [[NSString alloc] initWithFormat:@"%@",[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageString];
        self.contents = (id)image.CGImage;
        self.frame = frame;
    }
    return self;
}

-(void)removeMyAnimations
{
    [self removeAnimationForKey:@"timerAnimation"];
}

-(void)startAnimation
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"timerIndex"];
    
    anim.fromValue = [NSNumber numberWithInt:1]; // initial frame
    anim.toValue = [NSNumber numberWithInt:6]; // last frame + 1
    
    anim.duration = (float)1.0; // from the first frame to the 6th one in 1 second
    anim.repeatCount = HUGE_VALF; // just keep repeating it
    anim.autoreverses = NO;
    
    [self addAnimation:anim forKey:@"timerAnimation"]; // start
}

@end
