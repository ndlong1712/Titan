//
//  NetworkInformation.m
//  FTLPhotoUploader
//
//  Created by 阿部克幸 on 11/01/06.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//


#import "NetworkInformation.h"
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <unistd.h>		// for close(), etc etc... perhaps ioctl() is included in this header
#import <net/if.h>		// for struct ifconf, struct ifreq
#import <net/if_dl.h>	// for struct sockaddr_dl, LLADDR
#import <netinet/in.h>	// for some reason... I have no idea. Without this inet_ntoa call causes compile error
#import <net/ethernet.h>// for either_ntoa()
#import <arpa/inet.h>	// for inet_ntoa()

#include <stdio.h>
#include <string.h>
#include <ifaddrs.h>

#define NetworkInformation_IFCONF_BUFFER_LENGTH	4000
const int NetworkInformationInterfaceTypeIPv4 = AF_INET;
const int NetworkInformationInterfaceTypeMAC = AF_LINK;
const NSString *NetworkInformationInterfaceAddressKey = @"address";


@implementation NetworkInformation

/**
 * @brief 自分のIPアドレスを取得する。
 * @return 自分のIPアドレス
 */
+ (NSString*)getMyIPAddres {

	struct ifaddrs *addrs, *tempAddr;
	struct in_addr addr = {0};
	
	//NICの情報を取得する
	getifaddrs(&addrs);
	
	for (tempAddr = addrs; NULL != tempAddr; tempAddr = tempAddr->ifa_next) {
		//IPv4で、かつ、Wi-Fi接続のNICのみをログに出力する
		if ((AF_INET == tempAddr->ifa_addr->sa_family)
			&& [[NSString stringWithUTF8String:tempAddr->ifa_name] isEqualToString:@"en0"]) {
			//ifa_nameの種類
			//en0 = Wi-Fi
			//pdp_ip0 = 3G回線
			addr.s_addr = ((struct sockaddr_in *)(tempAddr->ifa_addr))->sin_addr.s_addr;

			//sin_familyの種類
			//AF_INET = 2 IPv4の判定に使う
			//AF_LINK = 18
			//AF_INET6 = 30 IPv6の判定に使う
			MGLog(@"ifa_addr[%s]", inet_ntoa(addr));
		}
	}

	NSString* ipStr = [NSString stringWithUTF8String:inet_ntoa(addr)];

	//メモリ解放を忘れちゃだめ
	freeifaddrs(addrs);

	return ipStr;
}

@end
