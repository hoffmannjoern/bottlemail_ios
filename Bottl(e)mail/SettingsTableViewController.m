//
//  SettingsTableViewController.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "NSUserDefaults+Settings.h"

@implementation SettingsTableViewController

-(void)setBottlesCount:(NSUInteger)bottles
{
  self.bottlesLabel.text = [NSString stringWithFormat:@"%lu", bottles];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.title = @"Settings";
  
  // UserName
  self.userNameTextField.delegate = self;
  self.userNameTextField.text = [NSUserDefaults userName];
  
  // UserId
  self.userIdTextField.delegate = self;
  self.userIdTextField.text = [NSUserDefaults userId];
  
  // Bottles
  NSUInteger bottles = [NSUserDefaults bottlesNumber];
  self.bottlesStepper.value = bottles;
  [self setBottlesCount:bottles];

  // Allow delete
  self.canDeleteLastMessageSwitch.on = [NSUserDefaults canDeleteLastMessage];
  
  // Set background image
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_blurred"]];
  self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  // Save user name
  if (textField == _userNameTextField)
    [NSUserDefaults saveUserName:textField.text];
  
  else if (textField == _userIdTextField)
    [NSUserDefaults saveUserId:textField.text];
  
  [textField resignFirstResponder];
  return true;
}

-(IBAction)generateNewUserId:(id)sender
{
  NSString *uuid = [[NSUUID UUID] UUIDString];
  [NSUserDefaults saveUserId:uuid];
  _userIdTextField.text = uuid;
}

-(IBAction)updateStepper:(UIStepper*)sender
{
  if (sender == _bottlesStepper)
  {
    [self setBottlesCount:sender.value];
    [NSUserDefaults saveBottlesNumber:sender.value];
  }
}

-(IBAction)didTapSwitch:(UISwitch *)sender
{
  if (sender == _canDeleteLastMessageSwitch)
    [NSUserDefaults saveCanDeleteLastMessage:sender.on];
}


@end
