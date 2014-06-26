//
//  MainViewBackGroundLayer.h
//  Marisa
//
//  Created by Aaron Eisses on 12-11-09.
//  Copyright (c) 2012 Aaron Eisses. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol AnimationLayerDelegate <NSObject>
-(void)updateDisplay;
@end

@interface AnimationLayer : CALayer
{
    id <AnimationLayerDelegate> myDelegate;
}

@property (readwrite, nonatomic) unsigned int timerIndex;
@property (retain, nonatomic) id <AnimationLayerDelegate> myDelegate;

-(id)initWithFile:(NSString *)fileName andFrame:(CGRect)frame;
-(void)removeMyAnimations;
-(void)startAnimation;

@end
