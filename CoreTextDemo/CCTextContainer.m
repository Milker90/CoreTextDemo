//
//  CCTextContainer.m
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import "CCTextContainer.h"
#import "CCCoreTextImageData.h"
#import "CCCoreTextLinkData.h"
#import <CoreText/CoreText.h>
#import "CTFrameParser.h"

typedef NS_ENUM(NSUInteger, CCTextContainerDataType) {
    kCCTextContainerDataImage = 0,
    kCCTextContainerDataLink,
};

@implementation CCTextContainer

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
    }
}

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
    }
    CFRetain(ctFrame);
    _ctFrame = ctFrame;
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    _imageArray = imageArray;
    [self fillImagePostion];
}

- (void)setLinkArray:(NSMutableArray *)linkArray {
    _linkArray = linkArray;
    [self fillLinkPostion];
}

- (void)fillLinkPostion {
    if (_linkArray.count == 0) {
        return;
    }
    
    NSArray *lines = (NSArray *)CTFrameGetLines(_ctFrame);
    if (lines.count == 0) {
        return;
    }
    
    NSInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
    NSInteger dIndex = 0;
    
    CCCoreTextLinkData *linkData = [_linkArray objectAtIndex:dIndex];
    
    for (NSInteger i = 0; i < lineCount; i++) {
        if (linkData == nil) {
            return;
        }
        
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        for (NSInteger j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)[runs objectAtIndex:j];
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            if (![attributes isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            NSString *type = [attributes objectForKey:kCCTextRunAttributedName];
            if (![type isEqualToString:@"link"]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y - descent;
            
            CGPathRef path = CTFrameGetPath(_ctFrame);
            CGRect colRect = CGPathGetBoundingBox(path);
            
            CGRect resRect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            linkData.linkPosition = resRect;
            dIndex++;
            if (dIndex == _linkArray.count) {
                break;
            } else {
                linkData = [_linkArray objectAtIndex:dIndex];
            }
        }
    }
}

- (void)fillImagePostion {
    if (_imageArray.count == 0) {
        return;
    }
    
    NSArray *lines = (NSArray *)CTFrameGetLines(_ctFrame);
    if (lines.count == 0) {
        return;
    }
    
    NSInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
    NSInteger dIndex = 0;
    
    CCCoreTextImageData *imageData = [_imageArray objectAtIndex:dIndex];
    
    for (NSInteger i = 0; i < lineCount; i++) {
        if (imageData == nil) {
            return;
        }
        
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        for (NSInteger j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)[runs objectAtIndex:j];
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef deleagte = (__bridge CTRunDelegateRef)[attributes objectForKey:(id)kCTRunDelegateAttributeName];
            if (deleagte == nil) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(deleagte);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            // 图片的descent是0
            runBounds.origin.y -= descent;
            
            CGPathRef path = CTFrameGetPath(_ctFrame);
            CGRect colRect = CGPathGetBoundingBox(path);
            
            CGRect resRect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            imageData.imagePosition = resRect;
            dIndex++;
            if (dIndex == _imageArray.count) {
                break;
            } else {
                imageData = [_imageArray objectAtIndex:dIndex];
            }
        }
    }
}

@end
