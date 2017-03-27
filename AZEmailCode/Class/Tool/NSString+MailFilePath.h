//
//  NSString+MailFilePath.h
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MailFilePath)

/**
 获取folder 文件路径
 
 @param fileName 文件名称
 @return 返回所在文件路径
 */
+ (NSString *)foldersArrayPathWith:(NSString *)fileName;

@end
