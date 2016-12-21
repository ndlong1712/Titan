//
//  NSData+commonDigest.m
//  DNPBViewer
//
//  Created by d669518 on 10/09/27.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import "NSData+commonDigest.h"


@implementation NSData(commonDigest)
+ (NSData *) dss_utf8Data: (NSString *) string
{
	const char* utf8str = [string UTF8String];
	NSData* data = [NSData dataWithBytes: utf8str length: strlen(utf8str)];
	return data;
}

- (NSData *) dss_sha256Digest
{
	unsigned char result[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256([self bytes], (CC_LONG)[self length], result);
	return [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *) dss_sha256String
{
    NSData *digest = [self dss_sha256Digest];
    NSString *result = [digest dss_hexaString];
	return result;
}
	 
- (NSString *) dss_hexaString
{
	unsigned int i;
	static const char *hexstr[16] = { "0", "1", "2", "3",
			        "4", "5", "6", "7",
			        "8", "9", "a", "b",
			        "c", "d", "e", "f" };
	const char *dataBuffer = (char *)[self bytes];
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	for (i=0; i<[self length]; i++) {
		uint8_t t1, t2;
		t1 = (0x00f0 & (dataBuffer[i])) >> 4;
		t2 =  0x000f & (dataBuffer[i]);
		[stringBuffer appendFormat:@"%s", hexstr[t1]];
		[stringBuffer appendFormat:@"%s", hexstr[t2]];
	}
		 
	return [stringBuffer copy];
}
@end
