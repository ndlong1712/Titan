#import "FTLUrlRequest.h"
#import "AsyncUdpSocket.h"

#define SEND_PORT                           7600            // UDP送信ポート
#define RECEIVE_PORT                        7601            // TCP受信ポート

@interface FTLUdpBroadcast : NSObject
{
    AsyncUdpSocket *UdpSocket;
}
    -(NSString *) getHostIPAddress;
    -(void)sendRequest;
@end
