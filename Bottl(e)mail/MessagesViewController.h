//
//  MessagesViewController.h
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class ModelData;

@interface MessagesViewController : JSQMessagesViewController

@property(nonatomic, strong) ModelData *modelData;

@end
