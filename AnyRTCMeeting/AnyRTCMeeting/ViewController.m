//
//  ViewController.m
//  AnyRTCMeeting
//
//  Created by jianqiangzhang on 2016/11/27.
//  Copyright © 2016年 jianqiangzhang. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "MeetingViewController.h"
#import "ASHUD.h"


@interface ViewController ()

@property (nonatomic, strong) UITextField *roomIdTextField;
@property (nonatomic, strong) UIButton *joinButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AnyRTC视频会议";
    
    [self.view addSubview:self.roomIdTextField];
    [self.view addSubview:self.joinButton];
    
    [self.roomIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(.9);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).multipliedBy(.6);
    }];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(.9);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@[@(50)]);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
}

#pragma mark - button event 

- (void)joinButtonEvent:(UIButton*)sender {
    MeetingViewController *meetingController = [MeetingViewController new];
    meetingController.meetingID = self.roomIdTextField.text;
    [self presentViewController:meetingController animated:YES completion:nil];
}

#pragma mark - get 

- (UITextField*)roomIdTextField {
    if (!_roomIdTextField) {
        _roomIdTextField = [UITextField new];
        _roomIdTextField.textAlignment = NSTextAlignmentCenter;
        _roomIdTextField.placeholder = @"请输入房间号";
        [_roomIdTextField becomeFirstResponder];
    }
    return _roomIdTextField;
}
- (UIButton*)joinButton {
    if (!_joinButton) {
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton addTarget:self action:@selector(joinButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_joinButton setTitle:@"加入会议" forState:UIControlStateNormal];
        [_joinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _joinButton.layer.cornerRadius = 6;
        _joinButton.layer.borderColor = [UIColor grayColor].CGColor;
        _joinButton.layer.borderWidth = .5;
    }
    return _joinButton;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.roomIdTextField isFirstResponder]) {
        [self.roomIdTextField resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
