//
//  Base64.m
//  DSSViewer
//
//  Created by SUGAWARA Seiki on 10/04/21.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import "Base64.h"

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

// Base64変換テーブル (0='A' 1='B'... 63='=')
static char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];

@implementation Base64

/**
 * @brief クラスの初期化を行う
 */
+ (void)initialize {
	
	// デコード用ルックアップテーブルの初期化
	memset(decodingTable, 0, ArrayLength(decodingTable));
	for (NSInteger i = 0; i < ArrayLength(encodingTable); i++) {
		decodingTable[encodingTable[i]] = i;
	}
}

/**
 * @brief Base64エンコード文字列を生成する。
 * @param[in] input エンコード対象の文字列
 * @length[in] length エンコード対象の文字列の長さ
 * @return Base64エンコード文字列
 */
+ (NSString*)encode:(const uint8_t*)input length:(NSInteger)length {
	
	// 出力先に最大パディング2byte + エンコード後のデータ長4/3のサイズを確保
	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	
	// 文字列から3文字ずつ取り出して4文字に変換
	for (NSInteger i = 0; i < length; i += 3) {
		NSInteger value = 0; // 変換用
		for (NSInteger j = i; j < (i + 3); j++) {
			value <<= 8;
			
			// 文字列長の判定： 文字列の参照位置 < エンコード対象の文字列長
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		// 6bitずつに分割
		NSInteger index = (i / 3) * 4; // 0, 4, 8, 12 ...
		output[index + 0] =                    encodingTable[(value >> 18) & 0x3F];
		output[index + 1] =                    encodingTable[(value >> 12) & 0x3F];
		output[index + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '='; // 余ったらパディング
		output[index + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '='; // 余ったらパディング		
	}
	
	return [[NSString alloc] initWithData:data
								  encoding:NSASCIIStringEncoding];
}

/**
 * @brief Base64エンコード文字列を生成する。
 * @param[in] rawBytes エンコード対象の文字列
 * @return Base64エンコード文字列
 */
+ (NSString*)encode:(NSData*)rawBytes {
	return [self encode:(const uint8_t*)rawBytes.bytes length:rawBytes.length];
}

/**
 * @brief Base64エンコード文字列をデコードした文字列を生成する。
 * @parama[in] string Base64デコード対象の文字列
 * @parama[in] inputLength Base64デコード対象の文字列の長さ
 * @return Base64デコード文字列
 */
+ (NSData*)decode:(const char*)string length:(NSInteger)inputLength {
	
	// 引数のチェック：デコード対象文字列が NULL または 文字列長が4バイト未満
	if ((string == NULL) || (inputLength % 4 != 0)) {
		return nil;
	}
	
	// パディング文字分の長さをカット
	while ((inputLength > 0) && (string[inputLength - 1] == '=')) {
		inputLength--;
	}
	
	// 出力先にデコード後のデータ長のサイズを確保
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* data = [NSMutableData dataWithLength:outputLength];
	uint8_t* output = data.mutableBytes;
	
	// 6bitずつに分割していたのを結合して8bitずつ取り出す
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	while (inputPoint < inputLength) {
		
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = (inputPoint < inputLength)? string[inputPoint++] : 'A'; // 元データが無い時は 'A' = \0 をセット
		char i3 = (inputPoint < inputLength)? string[inputPoint++] : 'A'; // 元データが無い時は 'A' = \0 をセット
		
		// 1byte目を取り出す
		output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
		
		// 2byte目を取り出す
		// デコードの判定：デコードデータの格納位置 < デコード後のデータ長
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
		}
		
		// 3byte目を取り出す
		// デコードの判定：デコードデータの格納位置 < デコード後のデータ長
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
		}
	}
	
	return data;
}

/**
 * @brief Base64エンコード文字列をデコードした文字列を生成する。
 * @parama[in] string Base64デコード対象の文字列
 * @return Base64デコード文字列
 */
+ (NSData*)decode:(NSString*)string {
	return [self decode:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}

@end
