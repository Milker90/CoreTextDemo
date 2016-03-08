//
//  CTDisplayView.m
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import "CTDisplayView.h"
#import <CoreText/CoreText.h>
#import "CCCoreTextImageData.h"
#import "CCCoreTextLinkData.h"

@implementation CTDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupTapGesture];
    }
    return self;
}

- (void)setupTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    // CTM解释http://www.tuicool.com/articles/Er6VNf6
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    // 翻转坐标系
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 文字
    if (_data && _data.ctFrame) {
        CTFrameDraw(_data.ctFrame, context);
    }
    
    // 图片
    if (_data.imageArray.count > 0) {
        for (NSInteger i = 0; i < _data.imageArray.count; i++) {
            /* 此处可以用view来代替来实现一下按下效果
            UIImageView *imageView = [UIImageView new];
            CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
            imageView.frame = CGRectApplyAffineTransform(imageData.imagePosition, transform);;
            UIImage *image = [UIImage imageNamed:imageData.name];
            imageView.image = image;
            [self addSubview:imageView];
            */
            
            CCCoreTextImageData *imageData = [_data.imageArray objectAtIndex:i];
            UIImage *image = [UIImage imageNamed:imageData.name];
            if (image) {
                CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
            }
        }
    }
}


#pragma mark
#pragma mark - Gesture
- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL hasFind = NO;
    CGPoint point = [gestureRecognizer locationInView:self];
    for (CCCoreTextImageData *data in _data.imageArray) {
        CGRect pRect = data.imagePosition;
        pRect.origin.y = self.bounds.size.height - pRect.origin.y - pRect.size.height;
        if (CGRectContainsPoint(pRect, point)) {
            NSLog(@"touch image in %@", data.name);
            hasFind = YES;
        }
    }
    
    if (!hasFind) {
        for (CCCoreTextLinkData *data in _data.linkArray) {
            CGRect pRect = data.linkPosition;
            pRect.origin.y = self.bounds.size.height - pRect.origin.y - pRect.size.height;
            if (CGRectContainsPoint(pRect, point)) {
                NSLog(@"touch link in %@", data.url);
                hasFind = YES;
            }
        }
    }
    
    if (!hasFind) {
        NSLog(@"no control has touch");
    }
}


@end
