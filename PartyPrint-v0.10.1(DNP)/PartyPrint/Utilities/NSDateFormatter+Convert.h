//
//  NSDateFormatter+Convert.h
//  FTLPhotoUploader
//
//  Created by Yamamoto on 12/07/06.
//  Copyright 2012 Dai Nippon Printing Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDateFormatter (Convert)

- (NSString *)ftl_stringFromDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone format:(NSString *)format;
- (NSDate *)ftl_dateFromString:(NSString *)string timeZone:(NSTimeZone *)timeZone format:(NSString *)format;

@end
