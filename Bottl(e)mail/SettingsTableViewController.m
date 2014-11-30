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
    self.userNameTextField.text = [NSUserDefaults userName];
}

#pragma mark - Text field delegate
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  return true;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
  if (textField == _userNameTextField)
    [NSUserDefaults saveUserName:textField.text];
  
  [textField resignFirstResponder];
}



@end
