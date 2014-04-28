//
//  UICollectionViewFlowLayout+WrapFix.m
//  
//
//  Created by Valentin Filip on 2/16/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "ADVCollectionViewFlowLayout.h"

@implementation ADVCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) {
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}

@end
