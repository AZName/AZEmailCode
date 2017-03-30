//
//  AZEmailMassger.m
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import "AZEmailMassger.h"
#import "NSString+MailFilePath.h"
@interface AZEmailMassger ()

@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;

@property (nonatomic, strong) MCOIMAPSession *imapSession;

@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;

@end

@implementation AZEmailMassger


//初始化
+ (AZEmailMassger *)standardMailMassage {
    static AZEmailMassger *massage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        massage = [[AZEmailMassger alloc]init];
    });
    return massage;
}


#pragma mark ---登录邮箱

- (void)loginWithUserName:(NSString *)name
                 password:(NSString *)password
               completion:(error)completion {
    NSArray *userNameArray = [name componentsSeparatedByString:@"@"];
    if (userNameArray.count == 2) {
        self.imapSession.username = name;//账号
        self.imapSession.password = password;//密码
        self.imapSession.hostname = [NSString stringWithFormat:@"imap.%@",userNameArray.lastObject];//收件地址
        self.imapSession.port = 993;//收件端口
        self.imapSession.checkCertificateEnabled = YES;//是否验证证书
        self.imapSession.connectionType = MCOConnectionTypeTLS;//
        AZEmailMassger * __weak weakSelf = self;
        self.imapSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
            @synchronized(weakSelf) {
                if (type != MCOConnectionLogTypeSentPrivate) {
                    //                    NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
            }
        };
    }
    
    self.imapCheckOp = [self.imapSession checkAccountOperation];
    //开始登录
    [self.imapCheckOp start:^(NSError * _Nullable error) {
        if (!error) {
            //登录成功
            [self getMailFolderWith:^(NSError *error, NSArray *folderArror) {
                
            }];
        }
        
        completion(error);
        
    }];
}
#pragma mark -  获取邮件

- (void)loadListWithPageCount:(NSInteger)pageCount
                     ofFolder:(NSString *)folder
                   compention:(completion)comletion{
    
    
    //获取邮件所有信息
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    //生成上下文对象
    MCOIMAPFolderInfoOperation *folderInfo = [self.imapSession folderInfoOperation:folder];
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        
        MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - (pageCount + 1)* 10, 9)];
        NSLog(@"%@",numbers);
        MCOIMAPFetchMessagesOperation *fetchOperation = [self.imapSession fetchMessagesByNumberOperationWithFolder:folder
                                                                                                       requestKind:requestKind
                                                                                                           numbers:numbers];
        
        [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            
            comletion(error,messages);
        }];
    }];
    
}


#pragma mark ---- 解析邮件


- (void)parsingMessageWith:(MCOIMAPMessage *)message
                    folder:(NSString *)folder
                completion:(emailContent)completion {
    
    MCOIMAPFetchParsedContentOperation *contentOperation =
    [self.imapSession fetchParsedMessageOperationWithFolder:folder uid:message.uid];
    [contentOperation start:^(NSError * _Nullable error, MCOMessageParser * _Nullable parser) {
        
        AZEmailContentModel *model = [[AZEmailContentModel alloc]init];
        model.bodyStr = [parser htmlBodyRendering]; //正文
        model.subjectStr = parser.header.subject;//主题
        model.attachments = parser.attachments;//附件
        model.fromModel.disPlayName = parser.header.from.displayName;//发件人名称
        model.fromModel.mailbox = parser.header.from.mailbox;//发件人地址
        NSMutableArray* addressToArray = [NSMutableArray array];//收件人
        for (MCOAddress* address in parser.header.to) {
            AZContactModel *conModel = [[AZContactModel alloc]init];
            conModel.disPlayName = address.displayName;
            conModel.mailbox = address.mailbox;
            [addressToArray addObject:conModel];
        }
        model.toArray = addressToArray;
        
        NSMutableArray* ccArray = [NSMutableArray array];//抄送
        
        for (MCOAddress* address in parser.header.to) {
            AZContactModel *conModel = [[AZContactModel alloc]init];
            conModel.disPlayName = address.displayName;
            conModel.mailbox = address.mailbox;
            [ccArray addObject:conModel];
        }
        model.ccArray = ccArray;
        NSMutableArray* bccArray = [NSMutableArray array];//密送
        for (MCOAddress* address in parser.header.to) {
            AZContactModel *conModel = [[AZContactModel alloc]init];
            conModel.disPlayName = address.displayName;
            conModel.mailbox = address.mailbox;
            [bccArray addObject:conModel];
        }

        model.bccArray = bccArray;
        
        completion(error,model);
        
    }];
    
}

#pragma mark -  获取所有文件夹 收件箱 已发邮件 草稿箱 已删除 垃圾邮件
- (void)getMailFolderWith:(void (^)(NSError *error, NSArray *folderArray))completion {
    NSArray *array = [NSArray arrayWithContentsOfFile:[NSString foldersArrayPathWith:self.imapSession.username]];
    if (!array) {
        
        MCOIMAPFetchFoldersOperation *imapFetchFolderOp = [_imapSession fetchAllFoldersOperation];
        
        [imapFetchFolderOp start:^(NSError * error, NSArray * folders) {
            NSMutableArray *foldersArray = [NSMutableArray array];
            for (MCOIMAPFolder *fdr in folders) {
                //获取文件夹路径
                NSArray * sections = [fdr.path componentsSeparatedByString:[NSString stringWithFormat:@"%c",fdr.delimiter]];
                NSString *folderName = [sections lastObject];
                const char *stringAsChar = [folderName cStringUsingEncoding:[NSString defaultCStringEncoding]];
                //获取文件夹名字
                folderName = [NSString stringWithCString:stringAsChar encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7_IMAP)];
                
                [foldersArray addObject:folderName];
                [foldersArray writeToFile:[NSString foldersArrayPathWith:self.imapSession.username] atomically:YES];
                completion(error,foldersArray);
                //                NSLog(@"%@-%@---%ld----",fdr.path,folderName,fdr.flags);
                
            }
        }];
    }else{
        NSError *error;
        completion(error,array);
    }
    
//        MCOIMAPMessageRenderingOperation
//        MCOIMAPFetchContentOperation
}

-(void)sendEmail:(NSString*)hosName
            port:(int)port
        userName:(NSString*)userName
        password:(NSString*)password
 fromDisplayName:(NSString*)fromDisplayName
      fromMaiBox:(NSString*)fromMaiBox
         toArray:(NSArray*)toArray
         ccArray:(NSArray*)ccArray
        bccArray:(NSArray*)bccArray
         subject:(NSString*)subject
         content:(NSString*)content
            file:(NSArray*)fileArray
     resultBlock:(void(^)(NSError* error))resultBlock {
    
    
    
}




- (MCOIMAPSession *) imapSession {
    if (!_imapSession) {
        _imapSession = [[MCOIMAPSession alloc]init];
        
    }
    return _imapSession;
}

@end
