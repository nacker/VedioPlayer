//
//  Video.m
//  播放器
//
//  Created by nacker on 2017/7/31.
//  Copyright © 2017年 nacker. All rights reserved.
//

#import "Video.h"

@implementation Video

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"description"]) {
        self.descriptionDe = value;
    }
}

@end
