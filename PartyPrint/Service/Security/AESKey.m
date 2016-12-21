//
//  AESKey.m
//
//  Created by d001042 on 11/01/12.
//  Copyright 2010 DNP Information Systems. All rights reserved.
//

#import "AESKey.h"

// 鍵ソース。本番鍵を直接埋め込むのではなく、Not、XORをかけてスクランブルしている。
// 鍵ソースの定義順序は、enum AESKEY_IDの定義値順序と等しい必要がある。
static const unsigned char scrumbledKeys[][16] = 
{
	// enum AESKEY_ID = commonSymmetricKeyの鍵ソース。
	{        //↓↓↓↓ 本番鍵偶数バイト目        ↓↓↓↓ 本番鍵奇数バイト目
		~(char)0x10 ^ (char)0xAA , ~(char)0x34 ^ (char)0xbb,
		~(char)0xFF ^ (char)0xAA , ~(char)0x80 ^ (char)0xbb,
		~(char)0xD2 ^ (char)0xAA , ~(char)0xC2 ^ (char)0xbb,
		~(char)0x5E ^ (char)0xAA , ~(char)0x5C ^ (char)0xbb,
		~(char)0xFC ^ (char)0xAA , ~(char)0x16 ^ (char)0xbb,
		~(char)0x33 ^ (char)0xAA , ~(char)0x9B ^ (char)0xbb,
		~(char)0x77 ^ (char)0xAA , ~(char)0xAA ^ (char)0xbb,
		~(char)0x02 ^ (char)0xAA , ~(char)0x27 ^ (char)0xbb		
	}
};

// 本番鍵のシングルトンインスタンス。
static NSMutableArray *masterKeys = nil;

@implementation AESKey
/**
 * @brief generate
 * @param [in] keyId 生成対象の鍵番号
 * @return 本番鍵値
 * @remark keyIdで指定されたAES鍵を返す。セキュリティ設計上、バイナリに埋め込む鍵値はスクランブル済。
 */
+ (NSData*)generate:(enum AESKEY_ID)keyId{
	
	// masterKeyはシングルトン実装としている。
	if( masterKeys == nil ){
		masterKeys = [[NSMutableArray alloc] init];
		
		// KEY_COUNTぶんのすべての鍵を一度だけ生成しメモリ上に保持する
		for (int j = 0; j < KEY_COUNT; j++) {
			
			NSData *masterKey;
			unsigned char masterKeyBytes[16];
			
			// スクランブルして埋め込んだバイト列を本番鍵値にデコードする
			for ( int i = 0 ; i < sizeof(masterKeyBytes) ; i++) {
				
				if( i%2 == 0 ){
					// 偶数番目は0xBBとの排他で埋め込み値を本来の鍵値に戻す
					masterKeyBytes[i] = ~scrumbledKeys[j][i] ^ 0xAA;
				}else{	
					// 奇数番目は0xAAとの排他で埋め込み値を本来の鍵値に戻す
					masterKeyBytes[i] = ~scrumbledKeys[j][i] ^ 0xBB;
				}
			}
			
			// 本番鍵をNSDataに変換し、保持
			masterKey = [[NSData alloc] initWithBytes:masterKeyBytes length:sizeof(masterKeyBytes)];
			[masterKeys addObject:masterKey];
		}
		
	}
	return [masterKeys objectAtIndex:(int)keyId];
}

/**
 * @brief releaseSingletonInstance
 * @remark 本番鍵をセットするために確保しているシングルトンインスタンスのメモリを解放する。メモリ足りないよイベントが来たら呼んでおくといいかも
 */
+ (void)releaseSingletonInstance
{
	masterKeys = nil;
}

@end
