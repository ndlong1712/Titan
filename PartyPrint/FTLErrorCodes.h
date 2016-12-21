//
//  FTLErrorCodes.h
//  FTLPhotoUploader
//
//  Created by d669518 on 11/01/13.
//  Copyright 2011 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//


// エラーコード採番ルール
// 「パッケージコード1桁+クラスコード1桁+詳細コード2桁」の数字4桁とする。
//	  ただ、枯渇する可能性が高いので、このファイルで一元管理し、頑張って重複を避ける

// ■パッケージコード一覧
// iPad						0
// iPhone					1
// Shared/					2
// Shared/utility			3
// Shared/domain/file		4
// Shared/domain/network	5
// Shared/domain/order		6
// Shared/domain/security	7

// =================================
// Shared/domain/network	5
// =================================

// --- FTLImageUploadRequest ---
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_AUTHID_CREATE					5101		// 認証情報生成に失敗
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_NOT_HTTP_RESPONSE				5102		// HTTPレスポンス以外を受信
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_NOT_HTTP_STATUS_CODE			5103		// HTTPレスポンスのステータスコードが200以外

// --- FTLImageUploadResponse ---
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_RESPONSE_PARAMETER				5201		// パラメータ不正
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_RESPONSE_SESSION				5202		// セッションID不正
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_RESPONSE_DECRYPT				5203		// 復号エラー
#define ERROR_CODE_NETWORK_IMAGE_UPLOAD_RESPONSE_SYSTEM					5299		// システムエラー

// --- FTLAuthenticationRequest ---
#define ERROR_CODE_NETWORK_AUTHENTICATION_AUTHID_CREATE					5301		// 認証情報生成に失敗
#define ERROR_CODE_NETWORK_AUTHENTICATION_NOT_HTTP_RESPONSE				5302		// HTTPレスポンス以外を受信
#define ERROR_CODE_NETWORK_AUTHENTICATION_NOT_HTTP_STATUS_CODE			5303		// HTTPレスポンスのステータスコードが200以外

// --- FTLAuthenticationResponse ---
#define ERROR_CODE_NETWORK_AUTHENTICATION_RESPONSE_PARAMETER			5401		// パラメータ不正
#define ERROR_CODE_NETWORK_AUTHENTICATION_RESPONSE_ORDERKEY				5402		// 注文キー不一致
#define ERROR_CODE_NETWORK_AUTHENTICATION_RESPONSE_AUTH					5403		// 認証エラー
#define ERROR_CODE_NETWORK_AUTHENTICATION_RESPONSE_SYSTEM				5499		// システムエラー

// --- FTLSupportSecurityModeRequest ---
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_AUTHID_CREATE			5501		// 認証情報生成に失敗
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_NOT_HTTP_RESPONSE		5502		// HTTPレスポンス以外を受信
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_NOT_HTTP_STATUS_CODE	5503		// HTTPレスポンスのステータスコードが200以外
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_AUTHID_CREATE_SYNCRO	5504		// 認証情報生成に失敗（同期通信時）

// --- FTLSupportSecurityModeResponse ---
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_PARAMETER		5601		// パラメータ不正
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_AUTH			5602		// 認証エラー
#define ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_SYSTEM		5699		// システムエラー

// --- FTLSettingDataRequest ---
#define ERROR_CODE_NETWORK_SETTING_DATA_AUTHID_CREATE					5701		// 認証情報生成に失敗
#define ERROR_CODE_NETWORK_SETTING_DATA_NOT_HTTP_RESPONSE				5702		// HTTPレスポンス以外を受信
#define ERROR_CODE_NETWORK_SETTING_DATA_NOT_HTTP_STATUS_CODE			5703		// HTTPレスポンスのステータスコードが200以外
#define ERROR_CODE_NETWORK_SETTING_DATA_AUTHID_CREATE_SYNCRO			5704		// 認証情報生成に失敗（同期通信時）

// --- FTLSettingDataRequestResponse ---
#define ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_PARAMETER				5801		// パラメータ不正
#define ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_AUTH					5802		// 認証エラー
#define ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_SYSTEM					5899		// システムエラー



