//
//  AESKey.m
//
//  Created by d001042 on 11/01/12.
//  Copyright 2010 DNP Information Systems. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AESKey : NSObject {
}
enum AESKEY_ID {
	commonSymmetricKey = 0,		// アプリ内共通鍵を指定
	KEY_COUNT = 1 // 鍵の数
};
// keyIdに指定したAES鍵を生成します
+ (NSData*)generate:(enum AESKEY_ID)keyId;

// AES鍵のシングルトンインスタンスを破棄します。メモリ不足イベントが飛んできたら呼んでください。
+ (void)releaseSingletonInstance;
@end
