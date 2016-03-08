//
//  CTFrameParser.m
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import "CTFrameParser.h"
#import <CoreText/CoreText.h>
#import "CCCoreTextImageData.h"
#import "CCCoreTextLinkData.h"

NSString *const kCCTextRunAttributedName = @"CCTextRunAttributedName";

static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void *ref) {
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@implementation CTFrameParser

+ (CCTextContainer *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config {
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *attributedString = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    CCTextContainer *data = [self parserAttributedContent:attributedString config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;
}

+ (NSAttributedString *)loadTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (arr && [arr isKindOfClass:[NSArray class]]) {
            NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
            for (NSInteger i = 0; i < arr.count; i++) {
                NSDictionary *dict = [arr objectAtIndex:i];
                NSString *type = [dict objectForKey:@"type"];
                if (type && [type isKindOfClass:[NSString class]]) {
                    if ([type isEqualToString:@"txt"]) {
                        NSAttributedString *tmpAttrString = [self parseAttributedContentFromDict:dict config:config];
                        [attributedString appendAttributedString:tmpAttrString];
                    } else if ([type isEqualToString:@"img"]) {
                        CCCoreTextImageData *imageData = [CCCoreTextImageData new];
                        imageData.name = [dict objectForKey:@"name"];
                        imageData.position = attributedString.length;
                        [imageArray addObject:imageData];
                        
                        // 创建空白占位符，并且设置它的 CTRunDelegate 信息
                        NSAttributedString *tmpAttrString = [self parseAttributedImageFromDict:dict config:config];
                        [attributedString appendAttributedString:tmpAttrString];
                    } else if ([type isEqualToString:@"link"]) {
                        CCCoreTextLinkData *linkData = [CCCoreTextLinkData new];
                        linkData.title = [dict objectForKey:@"content"];
                        linkData.url = [dict objectForKey:@"url"];
                        linkData.position = attributedString.length;
                        [linkArray addObject:linkData];
                        
                        NSAttributedString *tmpAttrString = [self parseAttributedContentFromDict:dict config:config];
                        [attributedString appendAttributedString:tmpAttrString];
                    }
                }
            }
            return attributedString;
        }
    }
    return nil;
}

+ (NSAttributedString *)parseAttributedImageFromDict:(NSDictionary *)dict config:(CTFrameParserConfig *)config {
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&callbacks, (__bridge void *)dict);
    
    unichar replacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&replacementChar length:1];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    [attributedString addAttribute:kCCTextRunAttributedName value:@"img" range:NSMakeRange(0, attributedString.length)];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attributedString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegateRef);
    CFRelease(delegateRef);
    return attributedString;
}

+ (NSMutableAttributedString *)parseAttributedContentFromDict:(NSDictionary *)dict config:(CTFrameParserConfig *)config {
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    NSString *colorName = [dict objectForKey:@"color"];
    if (colorName && [colorName isKindOfClass:[NSString class]]) {
        UIColor *color = [self colorFromTemplate:colorName];
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    
    NSNumber *fontSizeNumber = [dict objectForKey:@"size"];
    if (fontSizeNumber && [fontSizeNumber isKindOfClass:[NSNumber class]]) {
        NSInteger fontSize = [fontSizeNumber integerValue];
        if (fontSize > 0) {
            CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
            attributes[(id)kCTFontAttributeName] = (__bridge id)(fontRef);
        }
    }
    
    NSString *content = [dict objectForKey:@"content"];
    if (content && [content isKindOfClass:[NSString class]]) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
        NSString *type = [dict objectForKey:@"type"];
        if ([type isEqualToString:@"txt"]) {
            [attributedString addAttribute:kCCTextRunAttributedName value:@"txt" range:NSMakeRange(0, attributedString.length)];
        } else if ([type isEqualToString:@"link"]) {
            [attributedString addAttribute:kCCTextRunAttributedName value:@"link" range:NSMakeRange(0, attributedString.length)];
        }
        return attributedString;
    }
    
    return nil;
}

+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }
    return [UIColor blackColor];
}

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config
{
    CGFloat fontSize = config.fontSize;
    CTFontRef font = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {{kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing}, {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing}, {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}};
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);

    UIColor * textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)font;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(font);
    
    return dict;
}

+ (CCTextContainer *)parserAttributedContent:(NSAttributedString *)contentString config:(CTFrameParserConfig *)config
{
    // 创建 framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    // 获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 创建 frame
    CTFrameRef frame = [CTFrameParser createFrameRefWithFramesetterRef:framesetter config:config textHeight:textHeight];
    
    CCTextContainer *data = [CCTextContainer new];
    data.ctFrame = frame;
    data.height = textHeight;
    
    CFRelease(frame);
    CFRelease(framesetter);
    
    return data;
}

+ (CTFrameRef)createFrameRefWithFramesetterRef:(CTFramesetterRef)framesetter config:(CTFrameParserConfig *)config textHeight:(CGFloat)textHeight {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, textHeight));
    
    // 要考虑frame的释放问题
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    
    return frame;
}

@end
