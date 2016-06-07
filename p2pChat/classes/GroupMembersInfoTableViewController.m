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

@property (nonatomic,strong) NSString *membercountstr;
@property (weak, nonatomic) IBOutlet UILabel *groupMembersCount;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@property (nonatomic,strong) NSMutableArray *memberarray;

@end

@implementation GroupMembersInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    

    
    
    [[MyXMPP shareInstance] fetchMembersFromGroup:_groupName withCompletion:^(NSArray *members) {
        
        NSInteger count = [members count];
        count++;
        _memberarray = [[NSMutableArray alloc]initWithCapacity:count];
        for (int i=0; i<[members count];i++) {
            [_memberarray insertObject:[members objectAtIndex:i] atIndex:i];
        }
        XMPPJID *myjid = [[MyXMPP shareInstance]myjid];//获取自己的名片
        [_memberarray insertObject:myjid.user atIndex:[members count]];
        
        if ([_memberarray count]>2 ) {
            for (int i=0; i<3; i++) {
                [self addwithmembersarray:_memberarray count:i];
            }
            [self addInsertMemberButton];
            [self addBlankLabel];
        }else{
            for (int j=0; j<[_memberarray count];j++) {
                [self addwithmembersarray:_memberarray count:j];
            }
            [self addInsertMemberButton];//暂时没有实现添加加号按钮
            [self addBlankButton];
            [self addBlankLabel];
            [self addBlankLabel];
        }
        
        
        _membercountstr = [NSString stringWithFormat:@"%ld",(long)count];
        
        NSString *str = [NSString stringWithFormat:@"(%ld)",(unsigned long)count];
        [self.groupMembersCount setText:str];
        
        [self.groupNameLabel setText:_groupName];
        
        
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"groupmemberlist"]){
        id theSegue = segue.destinationViewController;
        [theSegue setValue:_groupName forKey:@"laterGroupName"];
        [theSegue setValue:_membercountstr forKey:@"count"];
    }
}

- (IBAction)wipeChatRecord:(UIButton *)sender {
    
}

- (IBAction)deleteRoomAndLeave:(UIButton *)sender {
    [[MyXMPP shareInstance]leaveChatRoom];
    [[MyXMPP shareInstance]destroyChatRoom];
}

#pragma mark-addmembers

- (void)addwithmembersarray:(NSArray *)members count:(int)i{
    
    XMPPJID *memberjid = [XMPPJID jidWithUser:[members objectAtIndex:i] domain:myDomain resource:@"iphone"];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:memberjid];
    [self addmemberwithphoto:friendVCard.photo];
    [self addmemberwithname:[members objectAtIndex:i]];
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

    [self.membersPhotoStack addArrangedSubview:insertbtn];
}

-(void)insertMemberAction{
    CreateGroupsViewController *creatgroup =[[CreateGroupsViewController alloc]init];
    creatgroup.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
    if(section == 2 || section == 3) {
        return 1;}
    else {
        return 2;}
        
}


@end
