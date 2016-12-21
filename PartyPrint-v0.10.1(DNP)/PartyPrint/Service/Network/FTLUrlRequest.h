//
//  FTLUrlRequest.h
//  FTLManager
//
//  Created by 阿部克幸 on 11/01/05.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FTL_SCI_READ_SIZE					2048			// バッファサイズ
#define FTL_METHOD_TYPE						@"POST"			// メソッドタイプ
#define FTL_JSESSIONID						@"JSESSIONID"	// セッションIDキー名

@interface FTLUrlRequest : NSObject {

@protected
	NSURLConnection	 *connection;				//!< URLコネクション
}

- (void)cancel;
+(NSString*)getHostAddress;
+(NSString*)getBroadcastAdress;
+(NSString*)getServiceURL;
+(NSString*)getServiceName;
+(void)resetHostAddress;
@end
