//
//  SettingsTableViewController.h
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>

// User
@property(nonatomic,weak) IBOutlet UITextField *userNameTextField;
@property(nonatomic,weak) IBOutlet UITextField *userIdTextField;

// Rack
@property(nonatomic,weak) IBOutlet UILabel    *bottlesLabel;
@property(nonatomic,weak) IBOutlet UIStepper  *bottlesStepper;

// Messages
@property(nonatomic,weak) IBOutlet UISwitch    *canDeleteLastMessageSwitch;

-(IBAction)generateNewUserId:(id)sender;
-(IBAction)updateStepper:(UIStepper*)sender;
-(IBAction)didTapSwitch:(UISwitch *)sender;

@end
