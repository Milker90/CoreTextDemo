//
//  CTFrameParser.h
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFrameParserConfig.h"
#import "CCTextContainer.h"

extern NSString *const kCCTextRunAttributedName;

@interface CTFrameParser : NSObject

+ (CCTextContainer *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config;
+ (CCTextContainer *)parserAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig *)config;

@end
