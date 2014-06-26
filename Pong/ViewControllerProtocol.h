//
//  ViewControllerProtocol.h
//  Pong
//
//  Created by Aaron Eisses on 2014-06-25.
//  Copyright (c) 2014 ratheroddcomputing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataService.h"

@protocol ViewControllerProtocol <NSObject>
@property (strong, nonatomic) DataService *dataService;
@end
