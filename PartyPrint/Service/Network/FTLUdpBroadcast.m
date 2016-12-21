#import "FTLUdpBroadcast.h"
#import "NetworkInformation.h"

@implementation FTLUdpBroadcast

BOOL procF;
NSString *HostAddr;

//UDP Broadcastを使用したIP特定処理
-(NSString *) getHostIPAddress{
    HostAddr = nil;
    procF = YES;
    
    [self sendRequest];
    
    while (procF == YES) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    if(UdpSocket != nil){
        [UdpSocket close];
    }
    UdpSocket.delegate = nil;
    return HostAddr;
}

-(void) sendRequest{
    //UdpSocket = [[[AsyncUdpSocket alloc]initWithDelegate:self] autorelease];
    UdpSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    NSData* sendData;
    NSString* message =  [NSString stringWithFormat:@"%@%@", @"PartyPrint_Q,", [NetworkInformation getMyIPAddres]];
    NSLog(@"Message :%@", message);
    NSString* hostaddr = [FTLUrlRequest getBroadcastAdress];
    NSLog(@"Host address: %@",hostaddr);
    sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [UdpSocket bindToPort:RECEIVE_PORT error:nil];
    [UdpSocket enableBroadcast:YES error:nil];
    [UdpSocket receiveWithTimeout:2.0 tag:0];
    [UdpSocket sendData:sendData toHost:hostaddr port:SEND_PORT withTimeout:2.0 tag:0];
    
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    
    NSString * message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSRange answer = [message rangeOfString:@"PartyPrint_A"];
    NSRange myip = [message rangeOfString:[NetworkInformation getMyIPAddres]];
    if(answer.location == NSNotFound){
        procF = YES;
        return NO;
    }
    if(myip.location == NSNotFound){
        procF = YES;
        return NO;
    }
    
    HostAddr = [host copy];
    procF = NO;
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    procF = NO;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    procF = NO;
}
@end
