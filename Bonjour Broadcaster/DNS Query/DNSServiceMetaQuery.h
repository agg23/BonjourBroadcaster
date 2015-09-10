//
//  DNSServiceMetaQuery.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#ifndef DNSServiceMetaQuery_h
#define DNSServiceMetaQuery_h

#include <dns_sd.h>
#include <arpa/nameser.h>
#include <sys/socket.h>
#include <net/if.h>
#include <assert.h>
#include <unistd.h>

#include <CoreFoundation/CoreFoundation.h>

typedef struct MyDNSServiceState {
    DNSServiceRef       service;
    CFRunLoopSourceRef  source;
    CFSocketRef         socket;
} MyDNSServiceState;

DNSServiceErrorType MyDNSServiceMetaQuery(MyDNSServiceState * query, DNSServiceQueryRecordReply callback);

void
DNSSD_API MyMetaQueryCallback(DNSServiceRef service, DNSServiceFlags flags, uint32_t interfaceID, DNSServiceErrorType error,
                              const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, void * context);

void
MyDNSServiceCleanUp(MyDNSServiceState * query);

#endif /* DNSServiceMetaQuery_h */
