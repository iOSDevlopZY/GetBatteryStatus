//
//  ViewController.m
//  GetBatteryStatus
//
//  Created by Developer_Yi on 2017/3/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "HYCircleProgressView.h"

@interface ViewController ()
{
    NSString *state1;
    HYCircleProgressView *progressView;
    UILabel *label6;
}

@end

#define  ApplicationState           app.applicationState
#define  UIStatusBarBatteryItemView [NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"]
#define  iOSState                   [[[UIDevice currentDevice] systemVersion] floatValue]
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [UIDevice currentDevice].batteryMonitoringEnabled=true;
    int level=[self getBatteryLevel];
    CGFloat percentageLevel=level/100.0f;
    UILabel *label0 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    label0.text=@"利用runtime测得电池电量为:";
    label0.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:label0];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 68, ScreenWidth, 44)];
    label.text=@"充满状态下可以查看电池损耗度";
    label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:label];
    //初始化HYCircleProgressView
    progressView = [[HYCircleProgressView alloc]initWithFrame:CGRectMake(ScreenWidth*0.2, ScreenHeight*0.2, ScreenWidth*0.6, ScreenHeight*0.3)];
    [self.view addSubview:progressView];
    
    [progressView setBackgroundStrokeColor:[UIColor lightGrayColor]];
    if(percentageLevel<=0.1)
    [progressView setProgressStrokeColor:[UIColor redColor]];
    else if(percentageLevel>0.1&&percentageLevel<=0.2)
    [progressView setProgressStrokeColor:[UIColor orangeColor]];
    else
    [progressView setProgressStrokeColor:[UIColor greenColor]];
    [progressView setProgress:percentageLevel animated:YES];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.1, ScreenHeight*0.55, ScreenWidth*0.3, 44)];
    label1.text=@"我的手机";
    label1.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:label1];

    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.1, ScreenHeight*0.65, ScreenWidth*0.2, 44)];
    label2.text=@"iOS版本";
    label2.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.6, ScreenHeight*0.55, ScreenWidth*0.35, 44)];
    label3.text=[UIDevice currentDevice].localizedModel;
    label3.font=[UIFont boldSystemFontOfSize:15.0f];
    label3.textColor=[UIColor lightGrayColor];
    label3.textAlignment=NSTextAlignmentRight;
    [self.view addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.6, ScreenHeight*0.65, ScreenWidth*0.35, 44)];
    label4.text=[NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
    label4.textAlignment=NSTextAlignmentRight;
    label4.font=[UIFont boldSystemFontOfSize:15.0f];
    label4.textColor=[UIColor lightGrayColor];
    [self.view addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.1, ScreenHeight*0.75, ScreenWidth*0.3, 44)];
    label5.text=@"充电状态";
    label5.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:label5];
    
    
    label6 = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*0.6, ScreenHeight*0.75, ScreenWidth*0.35, 44)];
    NSTimer *timer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    NSTimer *timer1=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(getBatteryLevel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:timer1 forMode:NSRunLoopCommonModes];
    label6.text=@"检测中。。。";
    label6.textAlignment=NSTextAlignmentRight;
    label6.font=[UIFont boldSystemFontOfSize:15.0f];
    label6.textColor=[UIColor lightGrayColor];
    [self.view addSubview:label6];
    
}

- (void)check
{
    UIDeviceBatteryState state= [UIDevice currentDevice].batteryState;
    
    switch (state) {
        case UIDeviceBatteryStateUnplugged:
            state1=@"未充电";
            break;
        case UIDeviceBatteryStateCharging:
            state1=@"正在充电";
            break;
        case UIDeviceBatteryStateFull:
            state1=@"完全充电";
        default:
            break;
    }
    label6.text=state1;
}
- (int)getBatteryLevel
{
    UIApplication *app=[UIApplication sharedApplication];
    //当APP处于活动或者不活动的情况都要获取
    if(ApplicationState==UIApplicationStateActive||ApplicationState==UIApplicationStateInactive||ApplicationState==UIApplicationStateBackground)
    {
        //获取刚才创建的app实例变量,并将statusBar赋值给它
        Ivar ivar=class_getInstanceVariable([app class], "_statusBar");
        id status=object_getIvar(app, ivar);
        //遍历status的子View
        for(id aView in [status subviews])
        {
            int batteryLevel=0;
            //继续向下遍历
             for (id bview in [aView subviews]) {
                  if ( UIStatusBarBatteryItemView== NSOrderedSame&& iOSState>=6.0)
                  {
                      //获取电量变量
                      Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                      if(ivar)
                      {
                          batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                          if (batteryLevel > 0 && batteryLevel <= 100) {
                              return batteryLevel;
                              
                          } else {
                              return 0;
                          }
                      }
                  }
             }
        }
    }
    return 0;
}


@end
