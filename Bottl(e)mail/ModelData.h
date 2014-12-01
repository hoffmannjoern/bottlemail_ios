//
//  ModelData.h
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class  JSQMessagesBubbleImage;

@interface ModelData : NSObject

@property(strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

-(void)addImageMessage:(UIImage*)image userId:(NSString*)userId userName:(NSString*)userName;
-(instancetype)initBottleIndex:(NSUInteger)bottleIndex;

@end
