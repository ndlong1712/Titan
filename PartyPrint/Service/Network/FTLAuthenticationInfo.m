//
//  FTLAuthenticationInfo.m
//  FTLManager
//
//  Created by 阿部克幸 on 11/01/12.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import "FTLAuthenticationInfo.h"
#import "AESCryptor.h"
#import "AESKey.h"
#import "NSData+commonDigest.h"

#define AUTH_BIN_FILE_NAME				@"auth"		// 認証情報ファイルのファイル名
#define AUTH_BIN_EXTENTION				@"bin"		// 認証情報ファイルの拡張子
#define AUTH_BIN_DELIMITATION			@"\t"		// 認証情報ファイルの区切り文字

@implementation FTLAuthenticationInfo

static FTLAuthenticationInfo *_sharedInstance;

/**
 * @brief クラスインスタンスを生成
 * @return クラスインスタンス
 */
+ (FTLAuthenticationInfo*)sharedInstance {
	
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [[self alloc] init];
		}
	}
	return _sharedInstance;
}

/**
 * @brief クラスインスタンスを生成
 * @return Hash化した認証情報
 */
- (NSString*)getHashedAuthenticationInfo{

	// auth.binを読み込む
	NSData *r_dat =[self getAuthBinInfo];

	// ファイルが開けなかった場合
	if(r_dat == nil) {
		return nil;
	}

	// AESで復号化
	AESCryptor *crypto = [AESCryptor sharedInstance];
	NSData *encryptKeyBytes = [AESKey generate:commonSymmetricKey];
	NSData *ivBytes = [COMMON_IV_KEY dataUsingEncoding:NSASCIIStringEncoding];

	
	NSData *plainData = [crypto decryptData:r_dat commonKey:encryptKeyBytes iv:ivBytes];

	if (plainData == nil) {
		return nil;
	}

	//NSData->NSString
	NSString *tmp_string = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];

	// tabで区切る
	NSArray *arrayTab = [tmp_string componentsSeparatedByString:AUTH_BIN_DELIMITATION];
	
	if ([arrayTab count] < 2 ) {
		return nil;
	}

	NSString* userId = [arrayTab objectAtIndex:0];			// ユーザID
	NSString* password = [arrayTab objectAtIndex:1];		// パスワード

	// plainテキスト
	NSString* plain = [NSString stringWithFormat:@"%@%@", userId, password];

	NSString* salt = [self getSalt];
	NSString* hashSeed = [NSString stringWithFormat:@"%@%@", plain, salt];

	// HASH計算
	NSString * val = [[NSData dss_utf8Data:hashSeed] dss_sha256String];

	// 認証情報生成
	NSString* result = [NSString stringWithFormat:@"%@%@", val, salt];

	return result;

}

/**
 * @brief Saltを取得する。
 * @return Salt値
 */
- (NSString*)getSalt{

	// 乱数を取得
	srand([[NSDate date] timeIntervalSinceReferenceDate]);
	NSUInteger randomNum = abs(rand() * 227);	// 227をかけている理由は、rand利用を推測した悪意のある第三者が、timeからval1の生成方法を導き出すのを防ぐため。227は素数。

	// 2桁にする
	NSString* saltString = [NSString stringWithFormat:@"%02d", (int)(randomNum % 100)];

	return saltString;
}

/**
 * @brief ユーザ／パスワードファイルを読み込む
 * @return ファイルデータ
 */
- (NSData*)getAuthBinInfo{
	
	// ファイルパスの取得
	NSString* r_file_path = [[NSBundle mainBundle] pathForResource:AUTH_BIN_FILE_NAME ofType:AUTH_BIN_EXTENTION];
	// ファイルハンドルからの読み込み
	NSFileHandle *r_file = [NSFileHandle fileHandleForReadingAtPath:r_file_path];
	NSData *r_dat =[r_file readDataToEndOfFile];
	
	// ファイルを閉じる
	[r_file closeFile];
	
	return r_dat;
}

@end
