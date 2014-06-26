//
//  BallImageView.h
//  Pong
//
//  Created by Aaron Eisses on 2014-06-21.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallView : UIView

@property (retain, nonatomic) NSNumber *speedX;
@property (retain, nonatomic) NSNumber *speedY;
@property (retain, nonatomic) UIView *paddle1;
@property (retain, nonatomic) UIView *paddle2;
@property (assign, nonatomic) BOOL isSlave;

- (void)update;

@end
