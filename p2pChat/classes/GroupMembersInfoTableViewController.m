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
#import "CreateGroupsViewController.h"



static double PhotoHigh = 25;
static double Width = 25;
static double LabelHigh = 15;

@interface GroupMembersInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *MembersCell;
@property (weak, nonatomic) IBOutlet UIStackView *membersPhotoStack;
@property (weak, nonatomic) IBOutlet UIStackView *membersNameStack;

@property (weak, nonatomic) IBOutlet UILabel *groupMembersCount;
@property (weak, nonatomic) IBOutlet UILabel *groupName;

@end

@implementation GroupMembersInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPJID *myjid = [[MyXMPP shareInstance]myjid];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:myjid];
    [self addmemberwithphoto:friendVCard.photo];
    [self addmemberwithname:myjid.user];
//    [self addmemberwithphoto:friendVCard.photo x:InitialPositionX y:InitialPositionY];
//    [self addmemberwithname:myjid.user x:InitialPositionX y:LabelPositionY];
    
    [[MyXMPP shareInstance] fetchMembersFromGroupWithCompletion:^(NSArray *members) {
        
        if ([members count]>1) {
            for (int i=0; i<2; i++) {
                [self addwithmembers:members count:i];
            }
            [self addInsertMemberButton];
            [self addBlankLabel];
        }else{
            int m = 0;
        for (m=0; m<[members count]; m++) {
            [self addwithmembers:members count:m];
            }
            m++;
            [self addInsertMemberButton];//暂时没有实现添加加号按钮
            [self addBlankButton];
            [self addBlankLabel];
            [self addBlankLabel];
        }
        
        NSUInteger count = [members count];
        count++;
        NSString *str = [NSString stringWithFormat:@"(%ld)",(unsigned long)count];
        [self.groupMembersCount setText:str];
        
        XMPPRoom *room = [[MyXMPP shareInstance]chatroom];
        [self.groupName setText:room.roomJID.user];
    }];
    
    
    

}

- (void)addwithmembers:(NSArray *)members count:(int)i{
    
    XMPPJID *memberjid = [XMPPJID jidWithUser:[members objectAtIndex:i] domain:myDomain resource:@"iphone"];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:memberjid];
    [self addmemberwithphoto:friendVCard.photo];
    [self addmemberwithname:[members objectAtIndex:i]];
//    [self addmemberwithphoto:friendVCard.photo x:InitialPositionX+(PhotoWidth+LengthBetweenBtns)*(i+1) y:InitialPositionY];
//    [self addmemberwithname:[members objectAtIndex:i] x:InitialPositionX+(PhotoWidth+LengthBetweenBtns)*(i+1) y:LabelPositionY];
}

- (void)addmemberwithphoto:(NSData *)imagedata{
    UIButton *memberphoto = [[UIButton alloc]init];
    memberphoto.layer.cornerRadius = 10;
    memberphoto.layer.masksToBounds = true;//为button添加圆角
    [memberphoto setBackgroundImage:[UIImage imageWithData:imagedata] forState:UIControlStateNormal];
    [self.membersPhotoStack addArrangedSubview:memberphoto];
    CGRect temp = memberphoto.frame;
    temp.size = CGSizeMake(Width, PhotoHigh);
    memberphoto.frame = temp;
}

- (void)addmemberwithname:(NSString *)name {
    UILabel *membername = [[UILabel alloc]init];
    membername.text = name;
    membername.adjustsFontSizeToFitWidth = YES;
    membername.textAlignment = NSTextAlignmentCenter;
    [self.membersNameStack addArrangedSubview:membername];
    CGRect temp = membername.frame;
    temp.size = CGSizeMake(Width, LabelHigh);
    membername.frame = temp;
}

- (void)addInsertMemberButton{
    UIButton *insertbtn = [[UIButton alloc]init];
    [insertbtn addTarget:self action:@selector(insertMemberAction) forControlEvents:UIControlEventTouchUpInside];
    insertbtn.layer.cornerRadius = 10;
    insertbtn.layer.masksToBounds = true;
    [insertbtn setBackgroundImage:[UIImage imageNamed:@"ic_add_bg_n.png"] forState:UIControlStateNormal];
    CGRect temp = insertbtn.frame;
    temp.size = CGSizeMake(Width, PhotoHigh);
    insertbtn.frame = temp;
    
//    insertbtn.frame = CGRectMake(InitialPositionX+(PhotoWidth+LengthBetweenBtns)*i, InitialPositionY, PhotoWidth, PhotoWidth);withlocation:(int)i
    [self.membersPhotoStack addArrangedSubview:insertbtn];
}

-(void)insertMemberAction{
    CreateGroupsViewController *creatgroup =[[CreateGroupsViewController alloc]init];
    creatgroup.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:creatgroup animated:YES completion:nil];
    UINavigationController *nvi = [[UINavigationController alloc]init];
    [self.navigationController pushViewController:creatgroup animated:YES];
}

-(void)addBlankLabel{
    UILabel *membername = [[UILabel alloc]init];
    membername.text = @"    ";
    membername.adjustsFontSizeToFitWidth = YES;
    [self.membersNameStack addArrangedSubview:membername];
    CGRect temp = membername.frame;
    temp.size = CGSizeMake(Width, LabelHigh);
    membername.frame = temp;

}

-(void)addBlankButton{
    UIButton *blankbtn = [[UIButton alloc]init];
    CGRect temp = blankbtn.frame;
    temp.size = CGSizeMake(Width, PhotoHigh);
    blankbtn.frame = temp;
    [blankbtn setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    [self.membersPhotoStack addArrangedSubview:blankbtn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
    if(section == 2 || section == 3) {
        return 1;}
    else {
            return 2;}
        
}


@end
