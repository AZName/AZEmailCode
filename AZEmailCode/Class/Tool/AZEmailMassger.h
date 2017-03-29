//
//  AZEmailMassger.h
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>
#import "AZEmailContentModel.h"

typedef void (^emailContent)(NSError *error, AZEmailContentModel *model);

typedef void(^error)(NSError *error);

typedef void (^completion) (NSError *error, NSArray <MCOIMAPMessage *> * messageArray);

@interface AZEmailMassger : NSObject



+ (AZEmailMassger *)standardMailMassage;


/**
 登录邮箱
 
 @param name 邮箱账号
 @param password 邮箱密码
 @param completion 返回值
 */
- (void)loginWithUserName:(NSString *)name
                 password:(NSString *)password
               completion:(error)completion;




/**
 获取文件夹
 
 @param completion 返回所有文件夹
 */
- (void)getMailFolderWith:(void (^)(NSError *error, NSArray *folderArray))completion;


/**
 获取邮件消息对象
 
 @param pageCount 消息页数
 @param folder 消息文件夹
 @param comletion 每次返回十条数据
 */
- (void)loadListWithPageCount:(NSInteger)pageCount
                     ofFolder:(NSString *)folder
                   compention:(completion)comletion;

/**
 解析消息数据
 
 @param message  消息对象
 @param folder 文件名字
 @param completion 返回解析的数据
 */

- (void)parsingMessageWith:(MCOIMAPMessage *)message
                    folder:(NSString *)folder
                completion:(emailContent)completion;

@end
