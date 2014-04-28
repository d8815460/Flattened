//
//  DataSource.m
//
//  Created by Valentin Filip on 10.04.2012.
//  Copyright (c) 2012 App Design Vault. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource


+ (NSArray *)timeline {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Timeline" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSDictionary *)userAccount {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"User-Account" ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:path];
}


+ (NSArray *)menu {
    return @[
                @{
                    @"title": @"Inbox",
                    @"image": @"menu-icon1",
                    @"count": @23
                    },
                @{
                    @"title": @"Sent emails",
                    @"image": @"menu-icon2"
                    },
                @{
                    @"title": @"Drafts",
                    @"image": @"menu-icon3",
                    @"count": @6
                    },
                @{
                    @"title": @"Trash",
                    @"image": @"menu-icon4"
                    },
                @{
                    @"title": @"Settings",
                    @"image": @"menu-icon5"
                    }
             ];
}

@end
