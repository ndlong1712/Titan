//
//  Base64.h
//  DSSViewer
//
//  Created by SUGAWARA Seiki on 10/04/21.
//  Copyright 2010 Dai Nippon Printing Co.,Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Base64 : NSObject {
	
}

+ (void) initialize;

+ (NSString*)encode:(NSData*)rawBytes;
+ (NSData*)decode:(NSString*)string;

@end
