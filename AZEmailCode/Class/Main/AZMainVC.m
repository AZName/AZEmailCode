//
//  AZMainVC.m
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import "AZMainVC.h"
#import "AZEmailMassger.h"
@interface AZMainVC ()

@end

@implementation AZMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AZEmailMassger standardMailMassage] loginWithUserName:@"964190389@qq.com" password:@"xafmpmdasrsqbbeb" completion:^(NSError *error) {
        if (!error) {
            NSLog(@"登录成功");
        }
    }];
    
    [[AZEmailMassger standardMailMassage] getMailFolderWith:^(NSError *error, NSArray *folderArray) {
        
    }];
    
    [[AZEmailMassger standardMailMassage] loadListWithPageCount:1 ofFolder:@"INBOX" compention:^(NSError *error, NSArray<MCOIMAPMessage *> *messageArray) {
        NSLog(@"-----%ld",messageArray.count);
        
        MCOIMAPMessage * message = messageArray.firstObject;
        
        [[AZEmailMassger standardMailMassage] parsingMessageWith:message folder:@"INBOX" completion:^(NSError *error, AZEmailContentModel *model) {
            //NSLog(@"%@",model.toArray);
            //NSLog(@"%@",model.fromModel.disPlayName);
        }];
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
