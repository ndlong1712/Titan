//
//  NSHTTPCookieStorage+Cookie.m
//  FTLPhotoUploader
//
//  Created by uchino on 13/09/26.
//
//

#import "NSHTTPCookieStorage+Cookie.h"

@implementation NSHTTPCookieStorage (ftl_Cookie)

/**
 * @brief 指定されたドメインに紐づくCookie情報を全て削除する
 * @param[in] domain ドメイン名
 */
+ (void)ftl_removeCookie:(NSString*)domain
{
    //共通クッキーストレージを取得
    NSHTTPCookieStorage *aStorage       = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray             *cookies        = [aStorage cookies];
    
    //特定のドメイン(xxxx.ne.jp)のクッキーを全て削除
    for (NSHTTPCookie *aCookie in cookies) {
        NSDictionary    *prop           = [aCookie properties];
        NSString        *cookieDomain   = [prop objectForKey:NSHTTPCookieDomain];
        
        if ([cookieDomain isEqualToString:domain]) {
            // 無効なクッキーへ入れ替え。(deleteCookieのみだとキャッシュが残るため)
            // 過去の時間を設定しクッキーを無効にする
            [prop setValue:[NSDate dateWithTimeIntervalSinceNow:-3600] forKey:NSHTTPCookieExpires];
            NSHTTPCookie *newCookie = [[NSHTTPCookie alloc] initWithProperties:prop];
            
            [aStorage deleteCookie:aCookie];
            [aStorage setCookie:newCookie];
        }
    }
}

@end
