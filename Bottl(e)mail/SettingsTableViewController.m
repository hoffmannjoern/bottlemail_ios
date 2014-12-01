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

@end
