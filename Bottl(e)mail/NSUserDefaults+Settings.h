//
//  NSUserDefaults+Settings.h
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Settings)
+(NSString*)userName;
+(void)saveUserName:(NSString*)userName;



@end
