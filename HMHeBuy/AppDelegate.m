//
//  AppDelegate.m
//  HMHeBuy
//
//  Created by mac on 15/10/11.
//  Copyright © 2015年 胡孟虎. All rights reserved.
//

#import "AppDelegate.h"
#import "ExceptionHandlers.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
// 处理推送消息
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification success:%@",userInfo);
    NSInteger badnum = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badnum++;
    application.applicationIconBadgeNumber = 4;
}
 //注册成功
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
     NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken success:%@",deviceToken);
     [UIApplication sharedApplication].applicationIconBadgeNumber = 4;
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings
{
    UIUserNotificationType allowTypes = [notificationSettings types];
    NSLog(@"didRegisterUserNotificationSettings:");
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    InstallUncaughtExceptionHandler();//
    if([[[UIDevice  currentDevice] systemVersion]floatValue]<8.0){
         [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert ];
    }else{  //8.0
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
        action1.identifier = @"action1";
        action1.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc]init];
        action2.identifier = @"action2";
        action2.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc]init];
        categorys.identifier = @"hmh";
        [categorys setActions:@[action1,action2] forContext:UIUserNotificationActionContextMinimal];
        NSSet *cateSet = [NSSet setWithObjects:categorys, nil];
        UIUserNotificationSettings *setting = [UIUserNotificationSettings  settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
         [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
 
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
 
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
