//
//  GroupMembersInfoTableViewController.m
//  XMPP
//
//  Created by admin on 16/5/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "GroupMembersInfoTableViewController.h"
#import "MyXMPP.h"
#import "MyXMPP+VCard.h"
#import "XMPPvCardTemp.h"
#import "MyXMPP+Group.h"


static double InitialPositionX = 15;
static double InitialPositionY = 12;
static double LabelPositionY = 83;
static double LengthBetweenBtns = 20;
static double PhotoWidth = 55;
static double LabelHigh = 20;

@interface GroupMembersInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *MembersCell;

@property (weak, nonatomic) IBOutlet UILabel *groupMembersCount;
@property (weak, nonatomic) IBOutlet UILabel *groupName;

@end

@implementation GroupMembersInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPJID *myjid = [[MyXMPP shareInstance]myjid];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:myjid];
    [self addmemberwithphoto:friendVCard.photo x:InitialPositionX y:InitialPositionY];
    [self addmemberwithname:myjid.user x:InitialPositionX y:LabelPositionY];
    
    [[MyXMPP shareInstance] fetchMembersFromGroupWithCompletion:^(NSArray *members) {
        
        if ([members count]>3) {
            for (int i=0; i<3; i++) {
                [self addwithmembers:members count:i];
            }
            [self addInsertMemberButtonwithlocation:4];
        }else{
            int m = 0;
        for (m=0; m<[members count]; m++) {
            [self addwithmembers:members count:m];
            }
            m++;
            [self addInsertMemberButtonwithlocation:m];//暂时没有实现添加加号按钮
        }
        
        NSUInteger count = [members count];
        count++;
        NSString *str = [NSString stringWithFormat:@"(%ld)",(unsigned long)count];
        [self.groupMembersCount setText:str];
    }];
    
    

}

- (void)addwithmembers:(NSArray *)members count:(int)i{
    
    XMPPJID *memberjid = [XMPPJID jidWithUser:[members objectAtIndex:i] domain:myDomain resource:@"iphone"];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:memberjid];
    [self addmemberwithphoto:friendVCard.photo x:InitialPositionX+(PhotoWidth+LengthBetweenBtns)*(i+1) y:InitialPositionY];
    [self addmemberwithname:[members objectAtIndex:i] x:InitialPositionX+(PhotoWidth+LengthBetweenBtns)*(i+1) y:LabelPositionY];
}

- (void)addmemberwithphoto:(NSData *)imagedata x:(CGFloat)x y:(CGFloat)y{
    UIButton *memberphoto = [[UIButton alloc]init];
    memberphoto.layer.cornerRadius = 10;
    memberphoto.layer.masksToBounds = true;
    [memberphoto setBackgroundImage:[UIImage imageWithData:imagedata] forState:UIControlStateNormal];
    memberphoto.frame = CGRectMake(x, y, PhotoWidth, PhotoWidth);
    [self.MembersCell.contentView addSubview:memberphoto];
}

- (void)addmemberwithname:(NSString *)name x:(CGFloat)x y:(CGFloat)y{
    UILabel *membername = [[UILabel alloc]init];
    membername.text = name;
    membername.frame = CGRectMake(x, y, PhotoWidth, LabelHigh);
    membername.textAlignment = NSTextAlignmentCenter;
    [self.MembersCell.contentView addSubview:membername];
}

- (void)addInsertMemberButtonwithlocation:(int)i{
    UIButton *insertbtn = [[UIButton alloc]init];
    insertbtn.layer.cornerRadius = 10;
    insertbtn.layer.masksToBounds = true;
    [insertbtn setBackgroundImage:[UIImage imageNamed:@"add_button.png"] forState:UIControlStateNormal];
    insertbtn.frame = CGRectMake(InitialPositionX+(PhotoWidth+LengthBetweenBtns)*i, InitialPositionY, PhotoWidth, PhotoWidth);
//    insertbtn.layer.borderColor=[UIColor blackColor].CGColor;
    [self.MembersCell.contentView addSubview:insertbtn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
//    return 1;
    if(section == 2 || section == 3) return 1;
    else if(section ==0) return 2;
    else return 3;
        
}


@end
