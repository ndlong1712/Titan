//
//  NSDateFormatter+Convert.m
//  FTLPhotoUploader
//
//  Created by Yamamoto on 12/07/06.
//  Copyright 2012 Dai Nippon Printing Co.,Ltd. All rights reserved.
//

#import "NSDateFormatter+Convert.h"


@implementation NSDateFormatter (Convert)

/**
 *  @brief USのロケールを取得する
 *  @note デフォルトのロケールはシステム設定に依存するため、24時間設定がON/OFFによって時刻の取り扱い方が変わる(たぶんiOSの不具合)HHの部分が00〜23で固定されるよう、このロケールを利用する。
 (24時間設定がOFFだと、HHは日本語圏では午前00〜午前11、午後00〜午後11という文字列表現になり、英語圏では AM00〜PM11という表現となる)
 */
+ (NSLocale*)ftl_staticUSLocale
{
    static NSLocale * ftl_usLocale = nil;
    
    if (ftl_usLocale == nil) {
        // 不変であり、一度しかアロケートする必要がない割には頻繁に利用するためシングルトン扱いにしている
        ftl_usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    
    return ftl_usLocale;
}

- (NSString *)ftl_stringFromDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone format:(NSString *)format
{
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    if (calender == nil) {
        calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
	[calender setTimeZone:timeZone];
	
	[self setCalendar:calender];
    [self setLocale:[NSDateFormatter ftl_staticUSLocale]];
	[self setTimeZone:timeZone];
	[self setDateFormat:format];

	 
	return [self stringFromDate:date];
}

- (NSDate *)ftl_dateFromString:(NSString *)string timeZone:(NSTimeZone *)timeZone format:(NSString *)format
{
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    if (calender == nil) {
        calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
	[calender setTimeZone:timeZone];
	
	[self setCalendar:calender];
    [self setLocale:[NSDateFormatter ftl_staticUSLocale]];
	[self setTimeZone:[calender timeZone]];
	[self setDateFormat:format];
	
	
	return [self dateFromString:string];
}

@end
