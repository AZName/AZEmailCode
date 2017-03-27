//
//  NSString+MailFilePath.m
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import "NSString+MailFilePath.h"

@implementation NSString (MailFilePath)

//获取 folder 文件路径
+ (NSString *)foldersArrayPathWith:(NSString *)fileName {
    NSString *foldersPath = [NSString stringWithFormat:@"%@/FoldersNames",[NSString getDefaultMailFilePath]];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:foldersPath]) {
        [manager createDirectoryAtPath:foldersPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@",foldersPath,fileName];
}

//创建文件目录
+ (NSString *)getDefaultMailFilePath {
    NSString *mailFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MailFile"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:mailFilePath]) {
        [manager createDirectoryAtPath:mailFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return mailFilePath;
    
}

@end
