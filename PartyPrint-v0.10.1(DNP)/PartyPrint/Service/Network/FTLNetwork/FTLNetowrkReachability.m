//
//  FTLNetowrkReachability.m
//  TestReachability
//
//  Created by SUGAWARA Seiki on 10/05/03.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "FTLNetowrkReachability.h"
#import "NetworkInformation.h"


@implementation FTLNetowrkReachability

static FTLNetowrkReachability *_sharedInstance;

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} FTLNetworkReachabilityStatus;

/**
 * @brief クラスインスタンスを生成
 * @return クラスインスタンス
 */
+ (id)defaultsReachability {
	
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [[self alloc] init];
		}
	}
	return _sharedInstance;
}

/**
 * @brief ネットワーク到達確認の結果から WiFi環境が利用可能か調べる
 * @param flags a
 * @return 利用可否
 */
- (FTLNetworkReachabilityStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags {
	
	// ネットワークコンフィグレーションが利用可能か
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		return NotReachable;
	}
	
	BOOL result = NotReachable;
	
	// 指定のノードネームかアドレスに到達できるか
	if ((flags & kSCNetworkReachabilityFlagsIsDirect) != 0) {
		result = ReachableViaWiFi;
	}
	
	return result;
}

- (FTLNetworkReachabilityStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
	
	// ネットワークコンフィグレーションが利用可能か
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		return NotReachable;
	}
	
	BOOL result = NotReachable;
	
	// 指定のノードネームかアドレスに到達できるが、最初にコネクションの確立が必要か
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// コネクションの確立が不要なので Wi-Fi環境と判断
		result = ReachableViaWiFi;
	}
	
	// コネクションは CFSocketStream API によって、要求に応じて確立されるか
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
		 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
		
		// コネクション確立時にパスワードや認証トークンなどを提供する必要があるか
		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
		{
			// コネクションの確立が不要なので Wi-Fi環境と判断
			result = ReachableViaWiFi;
		}
	}
	
	// EDGE, GPRS などのデータ伝送方式にて指定のノードネームかアドレスに到達できるか
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		result = ReachableViaWWAN;
	}
	
	return result;
}

/**
 * @brief WiFi環境が利用可能か調べる
 * @return 利用可能の時は YES を、利用できない時は NO を返す
 */
- (BOOL)isWiFiAccessPointReacheable {
	
	// ネットワーク到達確認用 Socket アドレスをセット
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	
	// ネットワーク到達確認用ハンドル取得	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&localWifiAddress);
	if (reachability == NULL) {
		return NO;
	}
	
	// 到達確認の実行
	SCNetworkReachabilityFlags flags;
	if (!SCNetworkReachabilityGetFlags(reachability, &flags)) {
		CFRelease(reachability);
		return NO;
	}
	
	CFRelease(reachability);

	// 到達確認の結果の解析
	FTLNetworkReachabilityStatus status = NotReachable;
	status = [self localWiFiStatusForFlags:flags];
	if (status == ReachableViaWiFi) {
		// WiFi環境への到達確認が取れたと判断
		return YES;
	}
	
	// WiFi環境への到達確認が取れないと判断
	return NO;
}


- (NSString*)ssidForFotolusioSystem
{
//	static NSString * const kFOTOLUSIO_SYSTEM_SSID_PREFIX = @"PrintRush";
	
	NSString * returnValue = nil;
	
	NSArray *array = (NSArray*)CFBridgingRelease(CNCopySupportedInterfaces());
	for (NSString * string in array) {		
		NSDictionary* dic = (NSDictionary*)CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)string));
		NSString * value = [dic objectForKey:(NSString*)(kCNNetworkInfoKeySSID)];
		
		// key=SSIDで、SSIDを取得可能。
/*		
		if ( [value hasPrefix:kFOTOLUSIO_SYSTEM_SSID_PREFIX]) {
			returnValue = [value copy];	// メモリリークの指摘が出るが、copyしないとdicのreleaseで巻き添えになって消えてしまう様子。
		}
*/
		// FOTOLUSIO_から始まるSSID以外のSSIDも許可するように変更。		
//		returnValue = [value copy];	// メモリリークの指摘が出るが、copyしないとdicのreleaseで巻き添えになって消えてしまう様子。
		if (value != nil) {
			returnValue = [NSString stringWithString:value];
		}
		
	}

	return returnValue;
}

@end
