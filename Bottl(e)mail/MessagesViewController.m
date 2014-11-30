//
//  MessagesViewController.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "MessagesViewController.h"

// Chat
#import <JSQMessage.h>
#import <JSQSystemSoundPlayer.h>
#import <JSQMessagesTimestampFormatter.h>

// Data
#import "ModelData.h"
#import "NSUserDefaults+Settings.h"

@interface MessagesViewController () <UIActionSheetDelegate>
@end

@implementation MessagesViewController

-(void)refreshMessages:(UIBarButtonItem *)sender
{
  
}

// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - JSQMessagesViewController method overrides
-(void)didPressSendButton:(UIButton *)button
          withMessageText:(NSString *)text
                 senderId:(NSString *)senderId
        senderDisplayName:(NSString *)senderDisplayName
                     date:(NSDate *)date
{
  
  /**
   *  Sending a message. Your implementation of this method should do *at least* the following:
   *
   *  1. Play sound (optional)
   *  2. Add new id<JSQMessageData> object to your data source
   *  3. Call `finishSendingMessage`
   */
  // [JSQSystemSoundPlayer jsq_playMessageSentSound];
  
  JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                           senderDisplayName:senderDisplayName
                                                        date:date
                                                        text:text];
  
  [self.modelData.messages addObject:message];
  [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Attachment"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Add photo", @"Add location", nil];
  
  [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  switch (buttonIndex) {
    case 0:
      // [self.demoData addPhotoMediaMessage];
      break;
      
    case 1:
    {
      /*
       __weak UICollectionView *weakView = self.collectionView;
       
       [self.demoData addLocationMediaMessageCompletion:^{
       [weakView reloadData];
       }];
       */
    }
      break;
  }
  
  // [JSQSystemSoundPlayer jsq_playMessageSentSound];
  [self finishSendingMessage];
}

// ------------------------------------------------------------------------------------------------------------------ //

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.modelData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  You may return nil here if you do not want bubbles.
   *  In this case, you should set the background color of your collection view cell's textView.
   *
   *  Otherwise, return your previously created bubble image data objects.
   */
  
  JSQMessage *message = [self.modelData.messages objectAtIndex:indexPath.item];
  
  if ([message.senderId isEqualToString:self.senderId]) {
    return (id) self.modelData.outgoingBubbleImageData;
  }
  
  return (id) self.modelData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  Return `nil` here if you do not want avatars.
   *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
   *
   *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
   *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
   *
   *  It is possible to have only outgoing avatars or only incoming avatars, too.
   */
  
  return nil;
  
  /**
   *  Return your previously created avatar image data objects.
   *
   *  Note: these the avatars will be sized according to these values:
   *
   *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
   *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
   *
   *  Override the defaults in `viewDidLoad`
   */
  /*
   JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
   
   if ([message.senderId isEqualToString:self.senderId]) {
   if (![NSUserDefaults outgoingAvatarSetting]) {
   return nil;
   }
   }
   else {
   if (![NSUserDefaults incomingAvatarSetting]) {
   return nil;
   }
   }
   
   
   return [self.demoData.avatars objectForKey:message.senderId];
   */
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
   *  The other label text delegate methods should follow a similar pattern.
   *
   *  Show a timestamp for every message
   */
  JSQMessage *message = [self.modelData.messages objectAtIndex:indexPath.item];
  return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
  JSQMessage *message = [self.modelData.messages objectAtIndex:indexPath.item];
  
  /**
   *  iOS7-style sender name labels
   */
  if ([message.senderId isEqualToString:self.senderId]) {
    return nil;
  }
  
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.modelData.messages objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:message.senderId]) {
      return nil;
    }
  }
  
  /**
   *  Don't specify attributes to use the defaults.
   */
  return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}


// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [self.modelData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  Override point for customizing cells
   */
  JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
  
  /**
   *  Configure almost *anything* on the cell
   *
   *  Text colors, label text, label colors, etc.
   *
   *
   *  DO NOT set `cell.textView.font` !
   *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
   *
   *
   *  DO NOT manipulate cell layout information!
   *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
   */
  
  JSQMessage *msg = [self.modelData.messages objectAtIndex:indexPath.item];
  
  if (!msg.isMediaMessage) {
    
    if ([msg.senderId isEqualToString:self.senderId]) {
      cell.textView.textColor = [UIColor blackColor];
    }
    else {
      cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
  }
  
  return cell;
}

// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
   */
  
  /**
   *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
   *  The other label height delegate methods should follow similarly
   *
   *  Show a timestamp for every message
   */
  return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
  /**
   *  iOS7-style sender name labels
   */
  JSQMessage *currentMessage = [self.modelData.messages objectAtIndex:indexPath.item];
  if ([[currentMessage senderId] isEqualToString:self.senderId]) {
    return 0.0f;
  }
  
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.modelData.messages objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
      return 0.0f;
    }
  }
  
  return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
  return 0.0f;
}

// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
  NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
  NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - UIViewController overrides
- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Messages";
  if (!_modelData) {
    _modelData = [[ModelData alloc] init];
  }
  
  self.senderDisplayName = [NSUserDefaults userName];
  self.senderId = [NSUserDefaults userId];
  
  // Disable avatar portraits
  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
  
  // Navigation setup
  self.showLoadEarlierMessagesHeader = false;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                            target:self
                                            action:@selector(refreshMessages:)];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
