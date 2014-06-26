//
//  ViewController.m
//  Pong
//
//  Created by Aaron Eisses on 2014-06-20.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    BOOL isSlave;
}
@end

@implementation ViewController

@synthesize dataService;

#pragma Overide Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataService = [[DataService alloc] init];
    self.dataService.mainDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _createGameButton.hidden = YES;
    _joinGameButton.hidden = YES;
//    _spinner.hidden = YES;
    [_spinner startAnimating];
    _waitingLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GameViewController *vc = (GameViewController*)segue.destinationViewController;
    vc.isSlave = isSlave;
    vc.dataService = self.dataService;
}

#pragma Public Methods
- (IBAction)createGame:(id)sender
{
    [self.dataService createGameAtLocation:(CGPoint){100,100}];
    isSlave = NO;
    _createGameButton.hidden = YES;
    [_spinner startAnimating];
    _spinner.hidden = NO;
    _waitingLabel.hidden = NO;
}

- (IBAction)joinGame:(id)sender;
{
    [self.dataService joinGameAtLocation:(CGPoint){100,100}];
    isSlave = YES;
}

- (void)createGame
{
    _createGameButton.hidden = NO;
    _joinGameButton.hidden = YES;
    [_spinner stopAnimating];
    _spinner.hidden = YES;
}

- (void)joinGame
{
    _createGameButton.hidden = YES;
    _joinGameButton.hidden = NO;
    [_spinner stopAnimating];
    _spinner.hidden = YES;
}

- (void)removeUser
{
    
}

#pragma DataService Delegate
- (void)gameReadyToPlay
{
    NSString *segue = @"gameViewSegue";
    [self performSegueWithIdentifier:segue sender:self];
}

- (void)doesGameExist:(BOOL)gameExist
{
    if (gameExist)
    {
        [self joinGame];
    }
    else
    {
        [self createGame];
    }
}

- (void)setUpGame
{
    if (!isSlave)
    {
        [self createGame];
    }
    else
    {
        [self joinGame];
    }
}

@end
