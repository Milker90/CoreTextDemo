//
//  ViewController.m
//  CoreTextDemo
//
//  Created by Allan Liu on 16/3/7.
//  Copyright © 2016年 NiceH. All rights reserved.
//

#import "ViewController.h"
#import "CTDisplayView.h"
#import "CTFrameParser.h"
#import "CCTextContainer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CTDisplayView *sview = [CTDisplayView new];
    sview.frame = CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height - 180);
    
    CTFrameParserConfig *config = [CTFrameParserConfig new];
    config.textColor = [UIColor redColor];
    config.fontSize = 15.0f;
    config.width = [[UIScreen mainScreen] bounds].size.width - 20;
    
    CCTextContainer *data = [CTFrameParser parseTemplateFile:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"] config:config];
    sview.data = data;
    sview.frame = CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, data.height);
    
    [self.view addSubview:sview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
