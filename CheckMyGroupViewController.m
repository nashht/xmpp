//
//  CheckMyGroupViewController.m
//  XMPP
//
//  Created by nashht on 16/6/7.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#define ID  @"MyGroupCell"
#import "CheckMyGroupViewController.h"

@interface CheckMyGroupViewController()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation CheckMyGroupViewController

- (void)viewDidLoad{
    self.view.backgroundColor = [UIColor grayColor];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }else{
        cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}

@end
