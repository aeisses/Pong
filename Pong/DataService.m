//
//  DataService.m
//  Pong
//
//  Created by Aaron Eisses on 2014-06-20.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import "DataService.h"

@interface DataService ()
@property (retain, nonatomic) GIConnection *myConnection;
@property (retain, nonatomic) GIRoom *myRoom;
@property (retain, nonatomic) GIRoom *myLobby;
@property (retain, nonatomic) GIUser *myUser;
@property (retain, nonatomic) NSString *myPaddle;
@property (retain, nonatomic) NSString *otherPaddle;
@property (retain, nonatomic) GIKey *paddleKeyX;
@property (retain, nonatomic) GIKey *paddleKeyY;
@property (retain, nonatomic) GIKey *ballKeyX;
@property (retain, nonatomic) GIKey *ballKeyY;
@property (retain, nonatomic) GIKey *scorePlayer1;
@property (retain, nonatomic) GIKey *scorePlayer2;

- (void)initConnection;
- (void)joinRoomWithUser:(NSString*)player atLocation:(CGPoint)location;
- (void)createUser:(NSString*)player;
- (void)createPaddleAtLocation:(CGPoint)location;
- (void)removePaddles;
- (void)exitGame;
@end

@implementation DataService

#pragma Public Methods
- (id)init
{
    if (self = [super init])
    {
        [self initConnection];
    }
    return self;
}

- (void)createGameAtLocation:(CGPoint)location
{
    self.myPaddle = @"Paddle1";
    self.otherPaddle = @"Paddle2";
    [self joinRoomWithUser:@"Player1" atLocation:location];
}

- (void)joinGameAtLocation:(CGPoint)location
{
    self.myPaddle = @"Paddle2";
    self.otherPaddle = @"Paddle1";
    [self joinRoomWithUser:@"Player2" atLocation:location];
}

- (void)checkForPlayer
{
    if (_myLobby)
    {
        if ([_myLobby.users count] > 1)
        {
            [_mainDelegate doesGameExist:YES];
            return;
        }
    }
    [_mainDelegate doesGameExist:NO];
}

- (void)cleanupMaster
{
    __weak typeof(self) weakSelf = self;
    [_scorePlayer1 removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
    {
        [_scorePlayer2 removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
        {
            [_ballKeyX removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
            {
                [_ballKeyY removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
                {
                    [weakSelf removePaddles];
                }];
            }];
        }];
    }];
}

- (void)cleanupSlave
{
    [self removePaddles];
}

- (void)updatePaddleAtLocation:(CGPoint)location
{
    GISetOptions *options = [GISetOptions optionsWithOverwrite:YES];
    [_paddleKeyX setValue:[NSNumber numberWithFloat:location.x] options:options];
    [_paddleKeyY setValue:[NSNumber numberWithFloat:location.y] options:options];
}

- (void)updateBallAtLocation:(CGPoint)location
{
    GISetOptions *options = [GISetOptions optionsWithOverwrite:YES];
    [_ballKeyX setValue:[NSNumber numberWithFloat:location.x] options:options];
    [_ballKeyY setValue:[NSNumber numberWithFloat:location.y] options:options];
}

- (void)updateScorePlayer1:(NSNumber*)number
{
    GISetOptions *options = [GISetOptions optionsWithOverwrite:YES];
    [_scorePlayer1 setValue:number options:options];
}

- (void)updateScorePlayer2:(NSNumber*)number
{
    GISetOptions *options = [GISetOptions optionsWithOverwrite:YES];
    [_scorePlayer2 setValue:number options:options];
}

- (void)otherPaddleLocation
{
    GIKey *keyX = [GIKey keyWithPath:[NSString stringWithFormat:@"/%@/x",_otherPaddle] room:_myRoom];
    [keyX getValueWithCompletion:^(NSError* error, id value, GIGetContext *context)
     {
         [_gameDelegate updatePaddle:(NSNumber *)value];
     }];
}

- (void)ballLocation
{
    GIKey *keyX = [GIKey keyWithPath:@"/Ball/x" room:_myRoom];
    [keyX getValueWithCompletion:^(NSError* error, id value, GIGetContext *context)
     {
         [_gameDelegate updateBallX:(NSNumber *)value];
     }];
    GIKey *keyY = [GIKey keyWithPath:@"/Ball/y" room:_myRoom];
    [keyY getValueWithCompletion:^(NSError* error, id value, GIGetContext *context)
     {
         [_gameDelegate updateBallY:(NSNumber *)value];
     }];
}

- (void)score
{
    GIKey *keyX = [GIKey keyWithPath:@"/scorePlayer1" room:_myRoom];
    [keyX getValueWithCompletion:^(NSError* error, id value, GIGetContext *context)
     {
         [_gameDelegate updateScorePlayer2:(NSNumber *)value];
     }];
    GIKey *keyY = [GIKey keyWithPath:@"/scorePlayer2" room:_myRoom];
    [keyY getValueWithCompletion:^(NSError* error, id value, GIGetContext *context)
     {
         [_gameDelegate updateScorePlayer1:(NSNumber *)value];
     }];
}

- (void)exitTheApp
{
    [_myConnection disconnect];
}

#pragma Private Methods
- (void)initConnection
{
    NSURL *url = [[NSURL alloc] initWithString:@"https://goinstant.net/983eeca39f63/my-application"];
    self.myConnection = [GIConnection connectionWithConnectUrl:url];
    __weak typeof(self) weakSelf = self;
    [_myConnection connectAndJoinRoom:@"lobby" completion:^(NSError *error, GIConnection *connection, GIRoom *room)
    {
        if (error)
        {
            NSLog(@"Error while connecting to GoInstant: %@",error);
            return;
        }
        if (![_myConnection isEqualToConnection:connection])
        {
            NSLog(@"Pretty sure the connections should be the same here, not sure why I have the connection in the completion block");
            return;
        }
        NSLog(@"connected to GOInstant");
        weakSelf.myLobby = room;
        [weakSelf checkForPlayer];
    }];
}

- (void)joinRoomWithUser:(NSString*)player atLocation:(CGPoint)location
{
    _myRoom = [GIRoom roomWithName:@"Game" connection:_myConnection];
    __weak typeof(self) weakSelf = self;
    [_myRoom joinWithCompletion:^(NSError *error)
    {
        [weakSelf.myRoom subscribe:weakSelf];
        [weakSelf createUser:player]; // May not need
        [weakSelf createPaddleAtLocation:location];
        if ([player isEqualToString:@"Player1"])
        {
            weakSelf.ballKeyX = [GIKey keyWithPath:@"/Ball/x" room:_myRoom];
            weakSelf.ballKeyY = [GIKey keyWithPath:@"/Ball/y" room:_myRoom];
            [_ballKeyX addValue:[NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width/2]];
            [_ballKeyY addValue:[NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height/2]];
            weakSelf.scorePlayer1 = [GIKey keyWithPath:@"/scorePlayer1" room:_myRoom];
            [_scorePlayer1 addValue:[NSNumber numberWithInt:0]];
            weakSelf.scorePlayer2 = [GIKey keyWithPath:@"/scorePlayer2" room:_myRoom];
            [_scorePlayer2 addValue:[NSNumber numberWithInt:0]];
        }
        else
        {
            [_mainDelegate gameReadyToPlay];
        }
    }];
}

- (void)createUser:(NSString*)player
{
    NSDictionary *dictionary = @{
                                 @"id": player,
                                 @"displayName": [player uppercaseString]
                                 };
    self.myUser = [GIUser userWithDictionary:dictionary];
}

- (void)createPaddleAtLocation:(CGPoint)location
{
    self.paddleKeyX = [GIKey keyWithPath:[NSString stringWithFormat:@"/%@/x",_myPaddle] room:_myRoom];
    self.paddleKeyY = [GIKey keyWithPath:[NSString stringWithFormat:@"/%@/y",_myPaddle] room:_myRoom];
    [_paddleKeyX addValue:[NSNumber numberWithFloat:location.x]];
    [_paddleKeyY addValue:[NSNumber numberWithFloat:location.y]];
}

- (void)removePaddles
{
    [_paddleKeyX removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
    {
        [_paddleKeyY removeValueWithCompletion:^(NSError* error, id value, GIRemoveContext *context)
        {
            [self exitGame];
            [_mainDelegate setUpGame];
        }];
    }];
}

- (void)exitGame
{
    [_myRoom unsubscribeAll];
    [_myRoom leave];
}

#pragma Room Observer
- (void)room:(GIRoom *)room joinedBy:(GIUser *)user
{
    if ([user.displayName hasPrefix:@"Guest"])
    {
        [_mainDelegate gameReadyToPlay];
    }
}

- (void)room:(GIRoom *)room leftBy:(GIUser *)user
{
    if ([user.displayName hasPrefix:@"Guest"])
    {
        [_gameDelegate leaveGame];
    }
}

// GIKeyObserver does not seem to be working with my second client
//#pragma Key Observer
//- (void)key:(GIKey *)key valueSet:(id)value context:(GISetContext *)context
//{
//    if ([key.path hasPrefix:[NSString stringWithFormat:@"/%@",_otherPaddle]])
//    {
//        if ([key.name isEqualToString:@"x"])
//        {
//            [_gameDelegate updatePaddle:(NSNumber*)value];
//        }
//    }
//}
//
//- (void)key:(GIKey *)key valueAdded:(id)value context:(GIAddContext *)context
//{
//    if ([key.path hasPrefix:[NSString stringWithFormat:@"/%@",_otherPaddle]])
//    {
//        
//    }
//}
//
//- (void)key:(GIKey *)key valueRemoved:(id)value context:(GIRemoveContext *)context
//{
//    
//}

@end
