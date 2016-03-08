//
//  CTDisplayView.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTextContainer.h"

@interface CTDisplayView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) CCTextContainer *data;

@end
