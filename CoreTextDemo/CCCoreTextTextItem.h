//
//  CCCoreTextTextItem.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/9.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCCoreTextTextItem : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) UIColor *color;

@end
