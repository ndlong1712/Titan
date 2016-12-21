//
//  FTLAuthenticationInfo.h
//  FTLManager
//
//  Created by 阿部克幸 on 11/01/12.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FTLAuthenticationInfo : NSObject

+ (FTLAuthenticationInfo*)sharedInstance;
- (NSString *)getHashedAuthenticationInfo;
- (NSString*)getSalt;
- (NSData*)getAuthBinInfo;

@end
