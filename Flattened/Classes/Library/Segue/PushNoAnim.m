//
//  PushNoAnim.m
//  
//
//  Created by Valentin Filip on 25.04.2012.
//  Copyright (c) 2012 App Design Vault. All rights reserved.
//

#import "PushNoAnim.h"

@implementation PushNoAnim

-(void) perform {
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
