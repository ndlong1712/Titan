//
//  FTLUrlRequest.m
//  FTLManager
//
//  Created by 阿部克幸 on 11/01/05.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import "FTLUrlRequest.h"
#import "NetworkInformation.h"
#import "AsyncUdpSocket.h"
#import "FTLUdpBroadcast.h"
#import <UIKit/UIKit.h>

@implementation FTLUrlRequest

static NSString* hostaddr;

/**
 * @breif リクエストをキャンセル
 */
- (void)cancel {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	// リクエストをキャンセルする
	[connection cancel];
}

/**
 *	@brief デストラクタ
 */
//- (void)dealloc
//{
//	[connection release];
//	[super dealloc];
//}

+(NSString *) getHostIPaddress{
    return hostaddr;
}
+(void)resetHostAddress{
    hostaddr = nil;
}

/**
 * @biref 端末が設定しているホストアドレスを取得
 * @return ホストアドレスを返す
 */
+(NSString*)getHostAddress {
	if(hostaddr == nil){
        FTLUdpBroadcast *broadcast = [FTLUdpBroadcast alloc];
        hostaddr = [broadcast getHostIPAddress];
        if(hostaddr != nil){
            return hostaddr;
        }
    }else{
        return hostaddr;
    }
	// 自分のIPアドレスを取得
	//[[NetworkInformation sharedInformation] refresh];
	//NSString *ipString = [[NetworkInformation sharedInformation] IPv4AddressForInterfaceName :@"en0"];

	NSString *ipString = [NetworkInformation getMyIPAddres];

	NSRange searchResult = [ipString rangeOfString:@"." options:NSBackwardsSearch];

	NSString *substr = [ipString substringToIndex:searchResult.location + 1];

//  [サーバーIPアドレスの変更]対応のため。
//	return [NSString stringWithFormat:@"%@1", substr];
    hostaddr = [[NSString stringWithFormat:@"%@100", substr] copy];
    return hostaddr;

//#warning 接続先が盛岡のテストPCになっています
//	NSLog(@"### IP:x.x.x.3 ###");
//	return [NSString stringWithFormat:@"%@3", substr];
}

+(NSString *)getBroadcastAdress{
	NSString *ipString = [NetworkInformation getMyIPAddres];

	NSRange searchResult = [ipString rangeOfString:@"." options:NSBackwardsSearch];

	NSString *substr = [ipString substringToIndex:searchResult.location + 1];

    return [NSString stringWithFormat:@"%@255", substr];
}

/**
 * @biref 接続先URLを返す
 * @return 接続先URL
 */
+(NSString*)getServiceURL {

	return [NSString stringWithFormat:@"http://%@:8080/uploadimage/%@", [FTLUrlRequest getHostAddress], [self getServiceName]];
}

/**
 * @biref 接続先サービス名を返す
 * @return 接続先サービス名
 */
+ (NSString*)getServiceName {
	// 実体は子供が実装
	return nil;
}

@end
