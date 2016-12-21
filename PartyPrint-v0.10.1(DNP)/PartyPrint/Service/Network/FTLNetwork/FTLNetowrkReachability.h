//
//  FTLNetowrkReachability.h
//  TestReachability
//
//  Created by SUGAWARA Seiki on 10/05/03.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTLNetowrkReachability : NSObject {

}

+ (id)defaultsReachability;

- (BOOL)isWiFiAccessPointReacheable;

- (NSString*)ssidForFotolusioSystem;

@end
