//
//  AESCryptor.h
//  DSSViewer
//
//  Created by SUGAWARA Seiki on 10/04/21.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@interface AESCryptor : NSObject

+ (AESCryptor*)sharedInstance;

- (NSData *)encryptData:(NSData *)plainData commonKey:(NSData *)key iv:(NSData *)iv;
- (NSData *)decryptData:(NSData *)cryptData commonKey:(NSData *)key iv:(NSData *)iv;

@end
