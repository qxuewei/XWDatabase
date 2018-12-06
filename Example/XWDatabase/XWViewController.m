//
//  XWViewController.m
//  XWDatabase
//
//  Created by qxuewei@yeah.net on 12/06/2018.
//  Copyright (c) 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWViewController.h"
#import "XWPerson.h"
#import "XWDatabase.h"

@interface XWViewController ()

@end

@implementation XWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self saveOnePerson];
    
    [self getOnePerson];
}

- (void)saveOnePerson
{
    XWPerson *person = [XWPerson testPerson:1];
    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {
        NSLog(@"saveOnePerson (%@)",isSuccess?@"成功":@"失败");
    }];
}

- (void)getOnePerson {
    XWPerson *person = [XWPerson new];
    person.cardID = @"1";
    [XWDatabase getModel:person completion:^(XWPerson * obj) {
        NSLog(@"getOnePerson (%@)",obj);
    }];
}

@end
