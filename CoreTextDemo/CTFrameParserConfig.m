//
//  CTFrameParserConfig.m
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import "CTFrameParserConfig.h"

@implementation CTFrameParserConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 200.0f;
        self.fontSize = 16.0f;
        self.lineSpace = 8.0f;
        self.textColor = [UIColor colorWithRed:108.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    }
    return self;
}

@end
