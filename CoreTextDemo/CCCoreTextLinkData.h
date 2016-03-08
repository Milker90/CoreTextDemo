//
//  CCCoreTextLinkData.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/8.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCCoreTextLinkData : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) CGRect linkPosition;

@end
