//
//  MeetingViewController.m
//  AnyRTCMeeting
//
//  Created by jianqiangzhang on 2016/11/29.
//  Copyright © 2016年 jianqiangzhang. All rights reserved.
//

#import "MeetingViewController.h"
#import <RTMeetEngine/RTMeetKit.h>
#import <RTMeetEngine/RTCCommon.h>
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "ASHUD.h"

static NSString *developerID = @"teameetingtest";
static NSString *token = @"c4cd1ab6c34ada58e622e75e41b46d6d";
static NSString *key = @"OPJXF3xnMqW+7MMTA4tRsZd6L41gnvrPcI25h9JCA4M";
static NSString *appID = @"meetingtest";

@interface MeetingViewController ()<RTMeetKitDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) RTMeetKit *meetKit;

@property (nonatomic, strong) NSMutableArray *remoteArray;

@property (strong, nonatomic) UIView *toolBarView;
@property (nonatomic, strong) UIButton *switchButton;

@property (nonatomic, strong) UIView *localVideoView;

@end

@implementation MeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remoteArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    _meetKit = [[RTMeetKit alloc] initWithDelegate:self];
#warning 请去AnyRTC官网申请账号
    [_meetKit InitEngineWithAnyrtcInfo:developerID andAppID:appID andAppKey:key andAppToken:token];
    //[_meetKit ConfigServerForPriCloud:@"192.168，7，208" andPort:9060];
    [self.view addSubview:self.localVideoView];
    [_meetKit SetVideoCapturer:self.localVideoView andUseFront:YES];
    [_meetKit Join:self.meetingID];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.toolBarView];
    

}
- (void)layoutSubView {
    
    int num = (int)self.remoteArray.count;
    switch (num) {
        case 0:
            break;
        case 1:
        {
             NSDictionary *dict = [self.remoteArray firstObject];
             UIView *videoView = [dict valueForKey:@"View"];
             videoView.frame = CGRectMake(CGRectGetMidX(self.view.frame)-videoView.frame.size.width/2, videoView.frame.origin.y, videoView.frame.size.width, videoView.frame.size.height);
        }
           break;
        case 2:
        {
            NSDictionary *dictFirst = [self.remoteArray firstObject];
            UIView *videoView = [dictFirst valueForKey:@"View"];
            videoView.frame = CGRectMake(CGRectGetMidX(self.view.frame)-videoView.frame.size.width, videoView.frame.origin.y, videoView.frame.size.width, videoView.frame.size.height);
            
            NSDictionary *dictLast = [self.remoteArray lastObject];
            UIView *videoViewLast = [dictLast valueForKey:@"View"];
            videoViewLast.frame = CGRectMake(CGRectGetMidX(self.view.frame), videoViewLast.frame.origin.y, videoViewLast.frame.size.width, videoViewLast.frame.size.height);
        }
            break;
        default:
            break;
    }
}

#pragma mark - button event 
- (void)closeButtonEvent:(UIButton*)sender {
    if (self.meetKit) {
        [self.meetKit Leave];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
- (void)switchButtonEvent:(UIButton*)sender {
    if (self.meetKit) {
        [self.meetKit SwitchCamera];
    }
}
- (void)audioButtonEvent:(UIButton*)sender {
    if (!self.meetKit) {
        return;
    }
    UIButton *muteButton = (UIButton*)sender;
    muteButton.selected = !muteButton.selected;
    if (muteButton.selected) {
        [self.meetKit SetAudioEnable:!muteButton.selected];
    }else{
        [self.meetKit SetAudioEnable:muteButton.selected];
    }
}
- (void)videoButtonEvent:(UIButton*)sender {
    if (!self.meetKit) {
        return;
    }
    UIButton *audioButton = (UIButton*)sender;
    audioButton.selected = !audioButton.selected;
    if (audioButton.selected) {
        [self.meetKit SetVideoEnable:!audioButton.selected];
    }else{
        [self.meetKit SetVideoEnable:audioButton.selected];
    }
}

#pragma mark - get
- (UIView*)localVideoView {
    if (!_localVideoView) {
        _localVideoView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _localVideoView;
}

- (UIButton*)switchButton {
    if (!_switchButton) {
        // 旋转摄像头
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchButton.frame = CGRectMake(20, 40, 45, 45);
        [_switchButton setImage:[UIImage imageNamed:@"btn_camera-turn_normal"] forState:UIControlStateNormal];
        [_switchButton addTarget:self action:@selector(switchButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UIView*)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, CGRectGetWidth(self.view.frame), 50)];
        // 挂断
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"btn_handup_normal"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:closeButton];
        
        // 音频开关
        UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [audioButton setImage:[UIImage imageNamed:@"btn_microphone_normal"] forState:UIControlStateNormal];
        [audioButton setImage:[UIImage imageNamed:@"btn_microphone_closed_normal"] forState:UIControlStateSelected];
        [audioButton addTarget:self action:@selector(audioButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:audioButton];
        
        // 视频开关
        UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton setImage:[UIImage imageNamed:@"btn_camera_normal"] forState:UIControlStateNormal];
        [videoButton setImage:[UIImage imageNamed:@"btn_camera_closed_normal"] forState:UIControlStateSelected];
        [videoButton addTarget:self action:@selector(videoButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:videoButton];
        
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_toolBarView.mas_height);
            make.width.equalTo(closeButton.mas_height);
            make.centerX.equalTo(_toolBarView.mas_centerX);
            make.centerY.equalTo(_toolBarView.mas_centerY);
        }];
        
        [audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_toolBarView.mas_height);
            make.width.equalTo(closeButton.mas_height);
            make.centerX.equalTo(_toolBarView.mas_centerX).multipliedBy(.5);
            make.centerY.equalTo(_toolBarView.mas_centerY);
        }];
        
        [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_toolBarView.mas_height);
            make.width.equalTo(closeButton.mas_height);
            make.centerX.equalTo(_toolBarView.mas_centerX).multipliedBy(1.5);
            make.centerY.equalTo(_toolBarView.mas_centerY);
        }];
    }
    return _toolBarView;
}
- (UIView*)getVideoViewWithStrID:(NSString*)publishID {
    NSInteger num = self.remoteArray.count;
    CGFloat videoWidth = CGRectGetWidth(self.view.frame)/4;
    CGFloat videoHeight = videoWidth*4/3;
    
    UIView *pullView;
    switch (num) {
        case 0:
            pullView = [[UIView alloc] init];
            pullView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2-videoWidth/2, CGRectGetMinY(self.toolBarView.frame)- 20 - videoHeight, videoWidth, videoHeight);
            pullView.layer.borderColor = [UIColor grayColor].CGColor;
            pullView.layer.borderWidth = .5;
            break;
        case 1:
        {
            NSDictionary *dictFirst =  [self.remoteArray firstObject];
            UIView *firstView = [dictFirst objectForKey:@"View"];
            firstView.frame = CGRectMake(CGRectGetMidX(self.view.frame)-videoWidth, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height);
            
            pullView = [[UIView alloc] init];
            pullView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2, firstView.frame.origin.y, videoWidth, videoHeight);
            pullView.layer.borderColor = [UIColor grayColor].CGColor;
            pullView.layer.borderWidth = .5;
        }
            break;
        case 2:
        {
            NSDictionary *dictLast =  [self.remoteArray lastObject];
            UIView *lastView = [dictLast objectForKey:@"View"];
            lastView.frame = CGRectMake(CGRectGetMidX(self.view.frame)-lastView.frame.size.width/2, lastView.frame.origin.y, lastView.frame.size.width, lastView.frame.size.height);
            
            NSDictionary *dictfirst =  [self.remoteArray firstObject];
            UIView *firstView = [dictfirst objectForKey:@"View"];
            firstView.frame = CGRectMake(CGRectGetMinX(lastView.frame)-firstView.frame.size.width, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height);
            
            
            pullView = [[UIView alloc] init];
            pullView.frame = CGRectMake(CGRectGetMaxX(lastView.frame), firstView.frame.origin.y, videoWidth, videoHeight);
            pullView.layer.borderColor = [UIColor grayColor].CGColor;
            pullView.layer.borderWidth = .5;
        }
            
            break;
            
        default:
            break;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:pullView,@"View",publishID,@"PeerID", [NSString stringWithFormat:@"%lu",(300+self.remoteArray.count)],@"buttonTag",nil];
    [self.remoteArray addObject:dict];
    return pullView;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - RTMeetKitDelegate
/**
 *  加入会议成功的回调
 *
 *  @param strAnyrtcId 会议号
 */
- (void)OnRTCJoinMeetOK:(NSString*)strAnyrtcId {
    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"进会成功" icon:nil];
}
/**
 *  加入会议室失败的回调
 *
 *  @param strAnyrtcId 会议号
 *  @param code        失败的code,可以根据code知道原因
 *  @param strReason   失败的原因
 */
- (void)OnRTCJoinMeetFailed:(NSString*)strAnyrtcId withCode:(int)code withReaso:(NSString*)strReason {
    
    [ASHUD showHUDWithCompleteStyleInView:self.view content:[self getErrorInfoForRtc:code] icon:nil];
    [self.meetKit Leave];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}
/**
 *  离开会议的回调
 *
 *  @param code      如果code的值为0 表示成功；如果非0，侧不成功
 */
- (void)OnRTCLeaveMeet:(int) code {
    if (code == AnyRTC_FORCE_EXIT)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请去AnyRTC官网申请账号,如有疑问请联系客服!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 502;
        [alertView show];
    }else{
        [ASHUD showHUDWithCompleteStyleInView:self.view content:[self getErrorInfoForRtc:code] icon:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}
/**
 *  其他会议者进入会议的回调（收到该回调，调用- (void)SetRTCVideoRender:(NSString*)strLivePeerID andRender:(UIView*)render;方法，设置对方的显示窗口）
 *
 *  @param strLivePeerID 其他会议者的ID
 */
- (void)OnRTCOpenVideoRender:(NSString*)strLivePeerID {
    UIView *videoView = [self getVideoViewWithStrID:strLivePeerID];
    [self.view addSubview:videoView];
    // 参照点~
    [self.view insertSubview:videoView belowSubview:self.switchButton];
    
    [self.meetKit SetRTCVideoRender:strLivePeerID andRender:videoView];
}
/**
 *  其他会议者离开的回调
 *
 *  @param strLivePeerID 其他会议者的ID（收到该回调，删除本地显示的对应的视频窗口）
 */
- (void)OnRTCCloseVideoRender:(NSString*)strLivePeerID {
    for (int i=0; i<self.remoteArray.count; i++) {
        NSDictionary *dict = [self.remoteArray objectAtIndex:i];
        if ([[dict objectForKey:@"PeerID"] isEqualToString:strLivePeerID]) {
            UIView *videoView = [dict objectForKey:@"View"];
            [videoView removeFromSuperview];
            [self.remoteArray removeObjectAtIndex:i];
            [self layoutSubView];
            break;
        }
    }
}
/**
 *  其他会议者视频窗口的对音视频的操作的回调（比如对方关闭了音频，对方关闭了视频）
 *
 *  @param strLivePeerID 其他会议者的ID
 */
- (void)OnRTCAVStatus:(NSString*)strLivePeerID withAudio:(BOOL)audio withVideo:(BOOL)video {
    
}

/**
 视频窗口大小的回调
 
 @param videoView 视频窗口
 @param size 视频的大小
 */
-(void) OnRtcViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"OnRtcViewChanged:%f,%f",size.width,size.height);
    if (videoView == _localVideoView) {
       // 本地视频大小，填充屏幕
        if (size.width>0&& size.height>0) {
            //Aspect fit local video view into a square box.
            CGRect remoteVideoFrame =
            AVMakeRectWithAspectRatioInsideRect(size, self.view.bounds);
            CGFloat scale = 1;
            if (remoteVideoFrame.size.width < remoteVideoFrame.size.height) {
                // Scale by height.
                scale = self.view.bounds.size.height / remoteVideoFrame.size.height;
            } else {
                // Scale by width.
                scale = self.view.bounds.size.width / remoteVideoFrame.size.width;
            }
            remoteVideoFrame.size.height *= scale;
            remoteVideoFrame.size.width *= scale;
           _localVideoView.frame = remoteVideoFrame;
          _localVideoView.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
            
        }else{
           _localVideoView.frame = self.view.bounds;
           _localVideoView.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
        }
    }else{
        
    }
}

// 获取错误信息
- (NSString*)getErrorInfoForRtc:(int)code {
    switch (code) {
        case AnyRTC_OK:
            return @"RTC:链接成功";
            break;
        case AnyRTC_UNKNOW:
            return @"RTC:未知错误";
            break;
        case AnyRTC_EXCEPTION:
            return @"RTC:SDK调用异常";
            break;
        case AnyRTC_NET_ERR:
            return @"RTC:网络错误";
            break;
        case AnyRTC_LIVE_ERR:
            return @"RTC:直播出错";
            break;
        case AnyRTC_BAD_REQ:
            return @"RTC:服务不支持的错误请求";
            break;
        case AnyRTC_AUTH_FAIL:
            return @"RTC:认证失败";
            break;
        case AnyRTC_NO_USER:
            return @"RTC:此开发者信息不存在";
            break;
        case AnyRTC_SQL_ERR:
            return @"RTC: 服务器内部数据库错误";
            break;
        case AnyRTC_ARREARS:
            return @"RTC:账号欠费";
            break;
        case AnyRTC_LOCKED:
            return @"RTC:账号被锁定";
            break;
        case AnyRTC_FORCE_EXIT:
            return @"RTC:强制离开";
            break;
        default:
            break;
    }
    return @"未知错误";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
