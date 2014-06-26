//
//  DataService.h
//  Pong
//
//  Created by Aaron Eisses on 2014-06-20.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "GoInstant.h"

@protocol DataServiceMainDelegate
- (void)gameReadyToPlay;
- (void)doesGameExist:(BOOL)gameExist;
- (void)setUpGame;
@end

@protocol DataServiceGameDelegate
- (void)updatePaddle:(NSNumber*)x;
- (void)updateBallX:(NSNumber*)x;
- (void)updateBallY:(NSNumber*)y;
- (void)updateScorePlayer1:(NSNumber*)score;
- (void)updateScorePlayer2:(NSNumber*)score;
- (void)leaveGame;
@end

// GIKeyObserver does not seem to be working with my second client
@interface DataService : NSObject <GIRoomObserver/*,GIKeyObserver*/>

@property (weak, nonatomic) id <DataServiceMainDelegate> mainDelegate;
@property (weak, nonatomic) id <DataServiceGameDelegate> gameDelegate;

- (id)init;
- (void)createGameAtLocation:(CGPoint)location;
- (void)joinGameAtLocation:(CGPoint)location;
- (void)checkForPlayer;
- (void)cleanupMaster;
- (void)cleanupSlave;
- (void)updatePaddleAtLocation:(CGPoint)location;
- (void)updateBallAtLocation:(CGPoint)location;
- (void)updateScorePlayer1:(NSNumber*)number;
- (void)updateScorePlayer2:(NSNumber*)number;
- (void)otherPaddleLocation;
- (void)ballLocation;
- (void)score;
- (void)exitTheApp;

@end
