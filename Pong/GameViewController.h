//
//  GameViewController.h
//  Pong
//
//  Created by Aaron Eisses on 2014-06-21.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationLayer.h"
#import "BallView.h"
#import "ViewControllerProtocol.h"

@interface GameViewController : UIViewController <DataServiceGameDelegate,AnimationLayerDelegate,ViewControllerProtocol>

@property (assign, nonatomic) BOOL isSlave;
@property (retain, nonatomic) IBOutlet UILabel *score1;
@property (retain, nonatomic) IBOutlet UILabel *score2;
@property (retain, nonatomic) UIView *paddle1;
@property (retain, nonatomic) UIView *paddle2;
@property (retain, nonatomic) BallView *ball;
@property (retain, nonatomic) AnimationLayer *animationLayer;

@end
