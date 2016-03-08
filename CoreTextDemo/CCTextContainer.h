//
//  CCTextContainer.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CCTextContainer : NSObject

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, assign) CGFloat height;

// 显示图片列表
@property (nonatomic, strong) NSMutableArray * imageArray;
// 显示的链接列表
@property (nonatomic, strong) NSMutableArray * linkArray;

@end
