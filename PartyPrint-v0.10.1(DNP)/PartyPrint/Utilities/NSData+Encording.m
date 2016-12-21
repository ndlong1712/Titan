//
//  NSData+Encording.m
//  FTLPhotoUploader
//
//  Created by Yamamoto on 12/08/22.
//  Copyright 2012 Dai Nippon Printing Co.,Ltd. All rights reserved.
//

#import "NSData+Encording.h"


@implementation NSData (Encording)

/**
 * @brief NSDataが表す文字コードを判別する
 * @returns NSStringEncoding
 */
- (NSStringEncoding)ftl_getEncording
{
    NSStringEncoding encordings[] = {
        NSUTF8StringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSUnicodeStringEncoding,
        NSUTF16StringEncoding,
        NSISO2022JPStringEncoding,
        NSASCIIStringEncoding,
        NSNEXTSTEPStringEncoding,
        NSISOLatin1StringEncoding,
        NSSymbolStringEncoding,
        NSNonLossyASCIIStringEncoding,
        NSISOLatin2StringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        NSWindowsCP1250StringEncoding,
        NSMacOSRomanStringEncoding,
        NSUTF16BigEndianStringEncoding,
        NSUTF16LittleEndianStringEncoding,
        NSUTF32StringEncoding,
        NSUTF32BigEndianStringEncoding,
        NSUTF32LittleEndianStringEncoding
    };
    
    int maxCount = sizeof(encordings) / sizeof(encordings[0]);
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    for (int index = 0; index < maxCount; index++) {
        // 指定の文字コードでData型を文字列型に変換できるか試す。
        NSString *value = [[NSString alloc] initWithData:self encoding:encordings[index]];
        if (value != nil) {
            encoding = encordings[index];
            break;
        }
    }
    
    return encoding;
}

@end
