//
//  NSData+commonDigest.h
//  DNPBViewer
//
//  Created by d669518 on 10/09/27.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface NSData(commonDigest)
+ (NSData *)dss_utf8Data:(NSString *)string;
- (NSData *)dss_sha256Digest;
- (NSString *)dss_sha256String;
- (NSString *)dss_hexaString;
@end
