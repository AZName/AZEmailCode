//
//  AZEmailContentModel.h
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZContactModel.h"
@interface AZEmailContentModel : NSObject

/**
 附件
 */
@property (nonatomic, copy)NSArray *attachments;

/**
 内容
 */
@property (nonatomic, copy)NSString *bodyStr;

/**
 主题
 */
@property (nonatomic, copy)NSString *subjectStr;

/**
 时间
 */
@property (nonatomic, copy)NSString *date;

/**
  id
 */
@property (nonatomic, copy)NSString *uid;

/**
 回复
 */
@property (nonatomic, copy)NSString *mailBox;
/**
 发件人
 */
@property (nonatomic, copy)AZContactModel *fromModel;

/**
 收件人
 */
@property (nonatomic, copy)NSArray *toArray;

/**
 抄送
 */
@property (nonatomic, copy)NSArray *ccArray;

/**
 密送
 */
@property (nonatomic, copy)NSArray *bccArray;

@end
