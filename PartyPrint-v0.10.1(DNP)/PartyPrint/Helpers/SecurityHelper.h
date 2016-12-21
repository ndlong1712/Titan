//
//  SecurityHelper.h
//  PartyPrint
//
//  Created by LongND9 on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityHelper : NSObject

+(NSData *)encryptData:(NSData*)orgData;

@end
