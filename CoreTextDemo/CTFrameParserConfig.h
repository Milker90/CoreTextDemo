//
//  CTFrameParserConfig.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTFrameParserConfig : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;

@end
