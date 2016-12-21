//
//  SecurityHelper.m
//  PartyPrint
//
//  Created by LongND9 on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

#import "SecurityHelper.h"
#import "AESCryptor.h"
#import "AESKey.h"

#define SERVER_REQUEST_KEY_NAME_AUTHID					@"AuthID"
#define SERVER_REQUEST_KEY_NAME_CRYPT_MODE				@"CryptoMode"
#define SERVER_REQUEST_KEY_NAME_CRYPT_MODE_VALUE		@"1"
#define SERVER_REQUEST_KEY_NAME_IMAGE_FILE				@"ImageFile"
#define IMAGE_ENCRYPTION  1
#define NONE_ENCRYPTION  0

@implementation SecurityHelper

/**
 * @brief 暗号化したデータを返す
 * @param[in] orgData 暗号化元データ
 */
+(NSData *)encryptData:(NSData*)orgData
{
    if ([SERVER_REQUEST_KEY_NAME_CRYPT_MODE_VALUE  isEqual: @"1"]) {
        
        // AESで暗号化
        AESCryptor *encrypto = [AESCryptor sharedInstance];
        NSData *encryptKeyBytes = [AESKey generate:commonSymmetricKey];
        NSData *ivBytes = [COMMON_IV_KEY dataUsingEncoding:NSASCIIStringEncoding];
        
        NSData *cryptData = [encrypto encryptData:orgData commonKey:encryptKeyBytes iv:ivBytes];
        
        if(cryptData == nil) {
            return nil;
        } else {
            return cryptData;
        }
    } else {
        // 暗号化なし
        return orgData;
    }
}

@end
