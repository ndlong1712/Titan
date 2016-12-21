//
//  NSHTTPCookieStorage+Cookie.h
//  FTLPhotoUploader
//
//  Created by uchino on 13/09/26.
//
//

#import <Foundation/Foundation.h>

@interface NSHTTPCookieStorage (ftl_Cookie)

+ (void)ftl_removeCookie:(NSString*)domain;

@end
