//
//  ModelData.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "ModelData.h"

// Base Encoder
#import <NSData+Base64.h>

// Message
#import <JSQMessage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQPhotoMediaItem.h>

static NSString *basePath = nil;
static NSString *const kUserId = @"userId";
static NSString *const kUserName = @"userName";
static NSString *const kDate = @"date";

// Media
static NSString *const kText = @"text";
static NSString *const kImage = @"image";
static NSString *const kLatitude = @"lat";
static NSString *const kLongitude = @"long";

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

// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Media
- (void)addImageMessage:(UIImage*)image userId:(NSString*)userId userName:(NSString*)userName
{
  JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
  JSQMessage *photoMessage = [JSQMessage messageWithSenderId:userId
                                                 displayName:userName
                                                       media:photoItem];
  [self.messages addObject:photoMessage];
}


// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Image Encoding
-(NSString*)base64EncodedStringFromImage:(UIImage*)image
{
  NSString *imageString = nil;
  if (image)
  {
    NSData *jpegData = UIImageJPEGRepresentation(image, 0.7);
    imageString = [jpegData base64EncodedString];
  }
  
  return imageString;
}

-(UIImage*)imageFromBase64EncodedString:(NSString*)imageString
{
  if (!imageString)
    return nil;
  
  NSData *data = [NSData dataFromBase64String:imageString];
  if (!data)
    return nil;
  
  return [[UIImage alloc] initWithData:data];
}

// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Serialization to JSON

-(void)extractUserFromMessage:(JSQMessage*)message toDictionary:(NSMutableDictionary*)dict
{
  dict[kUserId] = message.senderId;
  dict[kUserName] = message.senderDisplayName;
}

-(void)extractDateFromMessage:(JSQMessage*)message toDictionary:(NSMutableDictionary*)dict
{
  dict[kDate] = [NSNumber numberWithDouble:message.date.timeIntervalSinceReferenceDate];
}

-(void)extractTextFromMessage:(JSQMessage*)message toDictionary:(NSMutableDictionary*)dict
{
  dict[kText] = message.text;
}

-(void)extractPhotoFromMessage:(JSQPhotoMediaItem*)photo toDictionary:(NSMutableDictionary*)dict
{
  NSString *base64Image = [self base64EncodedStringFromImage:photo.image];
  if (base64Image)
    dict[kImage] = base64Image;
}

-(void)extractMediaFromMessage:(JSQMessage*)message toDictionary:(NSMutableDictionary*)dict
{
  JSQMediaItem *media = (JSQMediaItem*) message.media;
  
  // Photo
  if ([media isKindOfClass:[JSQPhotoMediaItem class]])
    [self extractPhotoFromMessage:(JSQPhotoMediaItem*)media toDictionary:dict];
  
  // Location
  // TODO...
}

-(NSArray*)jsonArrayFromMessages
{
  NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
  
  for (JSQMessage *message in _messages)
  {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [self extractUserFromMessage:message toDictionary:item];
    [self extractDateFromMessage:message toDictionary:item];
    
    if (message.isMediaMessage)
      [self extractMediaFromMessage:message toDictionary:item];
    else
      [self extractTextFromMessage:message toDictionary:item];
    
    [jsonArray addObject:item];
  }
  
  return jsonArray;
}

// -----------------------------------------------------------------------------------------------------------------  //
#pragma mark - Deserialization from JSON


-(NSMutableArray*)messagesFormJsonArray:(NSArray*)jsonArray
{
  NSMutableArray *array = [[NSMutableArray alloc] init];
  
  for (NSDictionary *item in jsonArray)
  {
    JSQMessage *message = nil;
    
    // User
    NSString *userId = item[kUserId] ? : @"0";
    NSString *userName = item[kUserName] ? : @"anonymous";

    // Date
    NSNumber *timeInterval = item[kDate];
    NSDate *date = timeInterval ? [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval.doubleValue] : [NSDate date];
    
    
    // Text
    NSString *text = item[kText];
    if (text)
    {
      message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:userName date:date text:text];
     [array addObject:message];
    }
    
    // Image
    NSString *base64Image = item[kImage];
    if (base64Image)
    {
      UIImage *image = [self imageFromBase64EncodedString:base64Image];
      if (image)
      {
        JSQPhotoMediaItem *photo = [[JSQPhotoMediaItem alloc] initWithImage:image];
        message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:userName date:date media:photo];
        [array addObject:message];
      }
    }
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
