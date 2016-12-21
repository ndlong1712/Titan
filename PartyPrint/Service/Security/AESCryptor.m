//
//  AESCryptor.m
//  DSSViewer
//
//  Created by SUGAWARA Seiki on 10/04/21.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import "AESCryptor.h"

@implementation AESCryptor

//! シングルトンクリプター
static AESCryptor* mySingletonCryptor = nil;

/**
 * @brief 暗号化方式をもとに鍵長を確定する
 * @param[in] algorithm 暗号化方式
 * @param[in] keyData 共通鍵
 * @param[in] ivData 初期化ベクトル
 */
static void FixKeyLengths(CCAlgorithm algorithm, NSMutableData* keyData, NSMutableData* ivData)
{
	NSUInteger keyLength = [keyData length];
	switch ( algorithm )
	{
		case kCCAlgorithmAES128:
			if (keyLength <= 16) {
				[keyData setLength: 16];	// 16Bytes以下なら 16Bytes
			} else if (keyLength <= 24) {
				[keyData setLength: 24];	// 24Bytes以下なら 24Bytes
			} else {
				[keyData setLength: 32];	// デフォルトは 32Bytes
			}
			break;
		default:
			break;
	}
	
	// 初期化ベクトルの長さは共通鍵の長さに合わせる
	[ivData setLength: [keyData length]];
}

/**
 * @brief 暗号/復号処理を行う
 * @param cryptor 暗号化クリプターオブジェクト
 * @param data 処理対象のバイト配列
 * @param status 処理結果格納用
 * @return 処理結果のバイト配列
 */
- (NSData*)runCryptor:(CCCryptorRef)cryptor data:(NSData*)data result:(CCCryptorStatus*)status {
	
	// 出力バッファサイズの取得
	size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[data length], true);
	void* buf = malloc(bufsize);
	size_t bufused = 0;
    size_t bytesTotal = 0;
	
	// 暗号/復号処理の実行
	*status = CCCryptorUpdate(cryptor, [data bytes], (size_t)[data length], buf, bufsize, &bufused);
	if (*status != kCCSuccess) {
		free(buf);
		return nil;
	}
    
	// 実行結果のサイズをセット
    bytesTotal += bufused;
	
	// 処理の後始末
	*status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
	if (*status != kCCSuccess) {
		free(buf);
		return nil;
	}
    
	// パディング分のサイズを追加
    bytesTotal += bufused;
	
	// NSData にキャストして返す
	return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}

/**
 * @brief 指定した暗号化アルゴリムに従ってバイト配列を暗号する
 * @param[in] algorithm 暗号化アルゴリズム
 * @param plainData 復号対象のバイト配列
 * @param key 共通鍵
 * @param iv 初期化ベクトル(IV)
 * @param options 暗号オプション
 * @param error エラー情報
 * @return 暗号したバイト配列
 */
- (NSData *)dataEncryptedUsingAlgorithm:(CCAlgorithm)algorithm
							  plainData:(NSData*)plainData
									key:(NSData*)key
				   initializationVector:(NSData*)iv
								options:(CCOptions)options
								  error:(CCCryptorStatus*)error {
	
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	// 共通鍵と初期化ベクトルのセット
	NSMutableData *keyData = (NSMutableData*)[key mutableCopy];
	NSMutableData *ivData =  (NSMutableData*)[iv mutableCopy];

	// アルゴリズムに従って共通鍵と初期化ベクトルのサイズを決定する
	FixKeyLengths(algorithm, keyData, ivData);
	
	// 暗号化クリプターの生成
	status = CCCryptorCreate(kCCEncrypt, algorithm, options, [keyData bytes], [keyData length], [ivData bytes], &cryptor);
	if (status != kCCSuccess) {
		if (error != NULL) {
			*error = status;
		}
		return nil;
	}
	
	// バイト配列の暗号
	NSData *result = [self runCryptor:cryptor data:plainData result:&status];
	if ((result == nil) && (error != NULL)) {
		*error = status;
	}
	
	// 暗号化クリプターの破棄
	CCCryptorRelease(cryptor);
	
	return result;
}

/**
 * @brief 指定した暗号化アルゴリムに従ってバイト配列を復号する
 * @param[in] algorithm 暗号化アルゴリズム
 * @param[in] cryptData 復号対象のバイト配列
 * @param key 共通鍵
 * @param iv 初期化ベクトル(IV)
 * @param options 暗号オプション
 * @param error エラー情報
 * @return 復号したバイト配列
 */
- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm
							  cryptData:(NSData*)cryptData
									key:(NSData*)key
				   initializationVector:(NSData*)iv
								options:(CCOptions)options
								  error:(CCCryptorStatus*)error {
	
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	// 共通鍵と初期化ベクトルのセット
	NSMutableData *keyData = (NSMutableData*)[key mutableCopy];
	NSMutableData *ivData =  (NSMutableData*)[iv mutableCopy];

	// アルゴリズムに従って共通鍵と初期化ベクトルのサイズを決定する
	FixKeyLengths(algorithm, keyData, ivData);
	
	// 暗号化クリプターの生成
	status = CCCryptorCreate(kCCDecrypt, algorithm, options, [keyData bytes], [keyData length], [ivData bytes], &cryptor);	
	if (status != kCCSuccess) {
		if (error != NULL) {
			*error = status;
		}
		return nil;
	}
	
	// バイト配列の復号
	NSData* result = [self runCryptor:cryptor data:cryptData result:&status];
	if ((result == nil) && (error != NULL)) {
		*error = status;
	}
	
	// 暗号化クリプターの破棄
	CCCryptorRelease(cryptor);
	
	return result;
}

/**
 * @brief 指定したバイト配列を暗号する
 * @param[in] plainData 暗号化対象のバイト配列
 * @param[in] key 共通鍵
 * @param[in] iv 初期化ベクトル値
 * @return 暗号化したバイト配列。暗号処理に失敗した時は nil を返す
 */
- (NSData *)encryptData:(NSData *)plainData commonKey:(NSData *)key iv:(NSData *)iv {
	
	CCCryptorStatus status = kCCSuccess;
	
	// 暗号処理
	NSData* cryptData = nil;
	cryptData = [self dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
										plainData:plainData
											  key:key
							 initializationVector:iv
										  options:kCCOptionPKCS7Padding // デフォルトの暗号モードはCBC
											error:&status];
	
	// 暗号化に失敗したらログを出力して nil を返す
	if ((cryptData == nil) || (status != kCCSuccess)) {
		MGLog(@"[ERROR] AESCryptor: encryptData Error. status=%d", status);
		return nil;
	}
	
	// 暗号化したバイト配列を返す
	return cryptData;
}

/**
 * @brief 指定したバイト配列を復号する
 * @param[in] cryptData 暗号化済みバイト配列
 * @param[in] key 共通鍵
 * @param[in] iv 初期化ベクトル
 * @return 復号したバイト配列。復号処理に失敗した時は nil を返す
 */
- (NSData *)decryptData:(NSData *)cryptData commonKey:(NSData *)key iv:(NSData *)iv {
	
	CCCryptorStatus status = kCCSuccess;
	
	// 復号処理
	NSData* plainData = nil;
	plainData = [self decryptedDataUsingAlgorithm:kCCAlgorithmAES128
										cryptData:cryptData
											  key:key
							 initializationVector:iv
										  options:kCCOptionPKCS7Padding // デフォルトの暗号モードはCBC
											error:&status];
	
	// 復号に失敗したらログを出力して nil を返す
	if ((plainData == nil) || (status != kCCSuccess)) {
		MGLog(@"[ERROR] AESCryptor: decryptData Error. status=%d", status);
		return nil;
	}
	
	// 復号したバイト配列を返す
	return plainData;	
}

#pragma mark -
#pragma mark Singleton メソッド

/**
 * @brief シングルトンインスタンスを返す
 * @return クリプターインスタンス
 */
+ (AESCryptor*)sharedInstance {
	
    @synchronized(self)
	{
        if (mySingletonCryptor == nil)
		{
            mySingletonCryptor = [[self alloc] init];
            
        }
    }
    return mySingletonCryptor;
}

/**
 * @brief ゾーンからオブジェクトを生成する
 * @param[in] zone ゾーン
 * @return オブジェクト
 */
+ (id)allocWithZone:(NSZone *)zone {
	
    @synchronized(self)
	{
        if (mySingletonCryptor == nil)
		{
            mySingletonCryptor = [super allocWithZone:zone];
            return mySingletonCryptor; 
        }
    }
    return nil;
}

/**
 * @brief ゾーンからオブジェクトを作って返す
 * @param[in] zone ゾーン
 * @return オブジェクト
 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

/**
 * @brief レシーバーの参照カウントを増加させてレシーバを返す
 * @return レシーバー
 */
//- (id)retain {
//    return self;
//}

/**
 * @brief レシーバーの参照カウントを返す
 * @return 参照カウント
 */
//- (unsigned)retainCount {
//	
//	// シングルトンオブジェクトなので最大値を返す
//    return UINT_MAX;
//}

/**
 * @brief オブジェクトのメモリを解放する
 */
//20130220
//警告対応
//- (void)release {
//    // シングルトンオブジェクトなので解放させない
//}

/**
 * @brief レシーバーを現在の自動解放プールに追加してレシーバを返す
 */
//- (id)autorelease {
//	// シングルトンオブジェクトなのでプールへの追加は行わずに自分自身を返す
//    return self;
//}

@end
