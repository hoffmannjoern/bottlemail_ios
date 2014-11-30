//
//  ModelData.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "ModelData.h"
#import <JSQMessage.h>
#import <JSQMessagesBubbleImageFactory.h>

static NSString *basePath = nil;
static NSString *const kUserId = @"userId";
static NSString *const kUserName = @"userName";
static NSString *const kText = @"text";
static NSString *const kDate = @"date";

@interface ModelData()
{
  NSString *_bottleName;
  NSString *_bottlePath;
}
@end


@implementation ModelData


// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Path helper

-(NSString*)nameForBottleIndex:(NSUInteger)index
{
  return [NSString stringWithFormat:@"bottle_%lu", index];
}

-(NSString*)pathForBottleName:(NSString*)name
{
  return [[basePath stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"json"];
}

-(NSArray*)jsonArrayFromMessages
{
  NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
  
  for (JSQMessage *message in _messages)
  {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setObject:message.senderId forKey:kUserId];
    [item setObject:message.senderDisplayName forKey:kUserName];
    [item setObject:message.text forKey:kText];
    [item setObject:[NSNumber numberWithDouble:message.date.timeIntervalSinceReferenceDate] forKey:kDate];
    [jsonArray addObject:item];
  }
  
  return jsonArray;
}

-(NSMutableArray*)messagesFormJsonArray:(NSArray*)jsonArray
{
  NSMutableArray *array = [[NSMutableArray alloc] init];
  
  for (NSDictionary *item in jsonArray)
  {
    NSString *userId = item[kUserId] ? : @"0";
    NSString *userName = item[kUserName] ? : @"anonymous";
    NSString *text = item[kText] ?  : @"";
    
    // Date
    NSNumber *timeInterval = item[kDate];
    NSDate *date = timeInterval ? [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval.doubleValue] : [NSDate date];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:userName date:date text:text];
    [array addObject:message];
  }
  
  return array;
}

-(NSData*)jsonDataFromObject:(id)object
{
  NSError *error = nil;
  return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
}

// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Messages
-(NSMutableArray*)messagesForCurrentBottle
{
  NSMutableArray *messages;
  
  // Load from file
  NSData  *jsonData = [NSData dataWithContentsOfFile:_bottlePath];
  NSArray *jsonArray = nil;
  if (jsonData)
  {
    NSError *error = nil;
    jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
  }
  
  if (jsonArray)
    messages = [self messagesFormJsonArray:jsonArray];
  
  // If no data, create array
  if (!messages)
    messages = [[NSMutableArray alloc] init];
  
  return messages;
}

-(void)saveMessages
{
  NSArray *array = [self jsonArrayFromMessages];
  NSData *jsonData = [self jsonDataFromObject:array];
                      
  BOOL written = [jsonData writeToFile:_bottlePath atomically:true];
  NSLog(@"Messages %@ saved!", written ? @"successfully" : @"not");
}

// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Init

-(instancetype)initBottleIndex:(NSUInteger)bottleIndex
{
  self = [super init];
  if (self)
  {
    _bottleName = [self nameForBottleIndex:bottleIndex];
    _bottlePath = [self pathForBottleName:_bottleName];
    _messages   = [self messagesForCurrentBottle];
    
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

-(instancetype)init
{
  return [self initBottleIndex:0];
}

-(void)dealloc
{
  [self saveMessages];
}

+(void)load
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  basePath = paths.count ? [paths lastObject] : nil;
}

@end
