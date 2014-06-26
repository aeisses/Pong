//
//  GameViewController.m
//  Pong
//
//  Created by Aaron Eisses on 2014-06-21.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()
{
    int loopCounter;
    CGPoint previousLocation;
}

@property (retain, nonatomic) UIPanGestureRecognizer *panGesture;

- (void)handlePan:(UIPanGestureRecognizer*)recongizer;
- (void)resetBall;

@end

@implementation GameViewController

@synthesize dataService;

#pragma DataService Delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loopCounter = 0;
    
    self.ball = [[BallView alloc] initWithFrame:(CGRect){150,265,20,20}];
    _ball.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.paddle1 = [[UIView alloc] initWithFrame:(CGRect){120,420,80,10}];
    _paddle1.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.paddle2 = [[UIView alloc] initWithFrame:(CGRect){120,80,80,10}];
    _paddle2.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [self.view addSubview:_paddle1];
    [self.view addSubview:_paddle2];
    [self.view addSubview:_ball];
    
    _ball.speedX = [NSNumber numberWithFloat:((float)(arc4random_uniform(1000)/500)-1)];
    _ball.speedY = [NSNumber numberWithFloat:((float)(arc4random_uniform(1000)/250)-2)];
    if ([_ball.speedY floatValue] == 0)
    {
        _ball.speedY = [NSNumber numberWithFloat:(float)-1.5];
    }
    _ball.paddle1 = _paddle1;
    _ball.paddle2 = _paddle2;
    _ball.isSlave = _isSlave;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:_panGesture];
    
    self.animationLayer = [[AnimationLayer alloc] init];
    _animationLayer.myDelegate = self;
    [self.view.layer addSublayer:self.animationLayer];
    [_animationLayer startAnimation];
    
    self.dataService.gameDelegate = self;
    [self.dataService updatePaddleAtLocation:_paddle1.frame.origin];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_animationLayer removeMyAnimations];
    _animationLayer.myDelegate = nil;
    [_animationLayer removeFromSuperlayer];
    self.dataService.gameDelegate = nil;
    [_panGesture removeTarget:self action:@selector(handlePan:)];
    if (!_isSlave)
    {
        [self.dataService cleanupMaster];
    }
    else
    {
        [self.dataService cleanupSlave];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetBall
{
    _ball.frame = (CGRect){150,265,_ball.frame.size};
    _ball.speedX = [NSNumber numberWithFloat:((float)(arc4random_uniform(1000)/500)-1)];
    _ball.speedY = [NSNumber numberWithFloat:((float)(arc4random_uniform(1000)/128)-4)];
    if ([_ball.speedY floatValue] == 0)
    {
        _ball.speedY = [NSNumber numberWithFloat:(float)-2.5];
    }
}

- (void)handlePan:(UISwipeGestureRecognizer*)recongizer
{
    CGPoint location = [recongizer locationInView:self.view];
    switch (recongizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            previousLocation = location;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint newLocation = (CGPoint){(_paddle1.frame.origin.x+(location.x-previousLocation.x)), _paddle1.frame.origin.y};
            previousLocation = location;
            if (newLocation.x < 20)
            {
                newLocation.x = 20;
            }
            if (newLocation.x > (300 - _paddle1.frame.size.width))
            {
                newLocation.x = 300 - _paddle1.frame.size.width;
            }
            
            [self.dataService updatePaddleAtLocation:newLocation];
            _paddle1.frame = (CGRect){newLocation.x,newLocation.y,_paddle1.frame.size};
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

#pragma DataSerivceGameDelegate
- (void)updatePaddle:(NSNumber*)x
{
    if ([x isKindOfClass:[NSNumber class]])
    {
        _paddle2.frame = (CGRect){(320-[x floatValue])-_paddle2.frame.size.width,_paddle2.frame.origin.y,_paddle2.frame.size};
    }
}

- (void)updateBallX:(NSNumber*)x
{
    if ([x isKindOfClass:[NSNumber class]])
    {
        _ball.center = (CGPoint){320-[x floatValue],_ball.center.y};
    }
}

- (void)updateBallY:(NSNumber*)y
{
    if ([y isKindOfClass:[NSNumber class]])
    {
        _ball.center = (CGPoint){_ball.center.x,(510-[y floatValue])};
    }
}

- (void)updateScorePlayer1:(NSNumber*)score
{
    if ([score isKindOfClass:[NSNumber class]])
    {
        _score1.text = [NSString stringWithFormat:@"%i",[score intValue]];
    }
}

- (void)updateScorePlayer2:(NSNumber*)score
{
    if ([score isKindOfClass:[NSNumber class]])
    {
        _score2.text = [NSString stringWithFormat:@"%i",[score intValue]];
    }
}

- (void)leaveGame
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma BallLayerDelegate
- (void)updateDisplay
{
    if (loopCounter > 5)
    {
        if (_isSlave)
        {
            [self.dataService ballLocation];
            [self.dataService score];
        }
        else
        {
            [_ball update];
            if ((_ball.frame.origin.y + _ball.frame.size.height) > 430)
            {
                NSNumber *score = [NSNumber numberWithInt:([_score2.text intValue] + 1)];
                _score2.text = [NSString stringWithFormat:@"%@",score];
                [self.dataService updateScorePlayer2:score];
                [self resetBall];
            }
            else if (_ball.frame.origin.y < 70)
            {
                NSNumber *score = [NSNumber numberWithInt:([_score1.text intValue] + 1)];
                _score1.text = [NSString stringWithFormat:@"%@",score];
                [self.dataService updateScorePlayer1:score];
                [self resetBall];
            }
            [self.dataService updateBallAtLocation:_ball.center];
        }
        [self.dataService otherPaddleLocation];
        loopCounter = 0;
    }
    else
    {
        loopCounter++;
    }
}

@end
