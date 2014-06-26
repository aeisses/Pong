//
//  ViewController.h
//  Pong
//
//  Created by Aaron Eisses on 2014-06-20.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "AnimationLayer.h"
#import "ViewControllerProtocol.h"

@interface ViewController : UIViewController <DataServiceMainDelegate,ViewControllerProtocol>

@property (retain, nonatomic) IBOutlet UILabel *waitingLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (retain, nonatomic) IBOutlet UIButton *createGameButton;
@property (retain, nonatomic) IBOutlet UIButton *joinGameButton;

- (IBAction)createGame:(id)sender;
- (IBAction)joinGame:(id)sender;
- (void)createGame;
- (void)joinGame;

@end

