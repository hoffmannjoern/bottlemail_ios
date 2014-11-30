//
//  NSUserDefaults+Settings.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "NSUserDefaults+Settings.h"

static NSString * const kUserName = @"kUserName";

@implementation NSUserDefaults (Settings)

+(NSString*)userName
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
}

+(void)saveUserName:(NSString*)userName
{
  [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUserName];
}

@end
