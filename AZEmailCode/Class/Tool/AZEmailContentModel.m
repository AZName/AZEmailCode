//
//  AZEmailContentModel.m
//  AZEmailCode
//
//  Created by 徐振 on 2017/3/27.
//  Copyright © 2017年 徐振. All rights reserved.
//

#import "AZEmailContentModel.h"

@implementation AZEmailContentModel

- (id)init {
    if (self = [super init]) {
        _fromModel =  [[AZContactModel alloc]init];
    }
    return self;
}

@end
