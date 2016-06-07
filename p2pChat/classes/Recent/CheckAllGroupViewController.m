//
//  CheckAllGroupViewController.m
//  XMPP
//
//  Created by nashht on 16/6/7.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define ID  @"AllGroupCell"
#import "CheckAllGroupViewController.h"
#import "MyXMPP+Group.h"
#import "ChatViewController.h"


@interface CheckAllGroupViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *members;
@end

@implementation CheckAllGroupViewController

//- (NSArray *)members{
//    if (!_members) {
//        _members = [NSArray array];
//    }
//    return _members;
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = @"查看所有群组";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    
    [[MyXMPP shareInstance]fetchAllRoomsWithCompletion:^(NSArray *members) {
        _members = members;
        [self.tableView reloadData];
    }];

}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }else{
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = _members[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *name = _members[indexPath.row];
//    NSArray *options = @[name, @0];

//    ChatViewController *chatVc = [[ChatViewController alloc] init];
//    [self.navigationController showViewController:chatVc sender:options];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"chat"];
    viewController.chatObjectString = name;
    viewController.p2pChat = NO;
    [self.navigationController pushViewController:viewController animated:YES];
   
//    [self.navigationController ]
//    [self.navigationController showViewController:viewController sender:options];
}

@end