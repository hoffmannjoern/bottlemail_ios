//
//  ModelData.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "ModelData.h"
#import <JSQMessagesBubbleImageFactory.h>


@implementation ModelData


-(instancetype)init
{
  self = [super init];
  if (self)
  {
    _messages = [[NSMutableArray alloc] init];
    
    
    /**
     *  Create message bubble images objects.
     *  Be sure to create your bubble images one time and reuse them for good performance.
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor greenColor]];
    self.incomingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lightGrayColor]];
  }
  
  return self;
}

@end
