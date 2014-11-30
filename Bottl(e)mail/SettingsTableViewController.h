//
//  SettingsTableViewController.h
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>

@property(nonatomic,weak) IBOutlet UITextField *userNameTextField;

@end
