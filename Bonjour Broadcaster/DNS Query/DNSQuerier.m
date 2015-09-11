//
//  DNSQuerier.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "DNSQuerier.h"

#import "ServiceListingTopLevelItem.h"
#import "NameResolverNetServiceBrowser.h"

#include <dns_sd.h>
#include <arpa/nameser.h>
#include <sys/socket.h>
#include <net/if.h>
#include <assert.h>
#include <unistd.h>

#define MAX_DOMAIN_LABEL 63
#define MAX_DOMAIN_NAME 255
#define kServiceMetaQueryName  "_services._dns-sd._udp.local."

@interface DNSQuerier ()

@property (strong, nonatomic) NSNetServiceBrowser *netServiceBrowser;
@property (strong, nonatomic) NSMutableArray *serviceNameResolvers;
@property (nonatomic) BOOL searchingTopLevel;
@property (nonatomic) NSInteger index;

@end

@implementation DNSQuerier

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.detectedServices = [NSArray array];
        self.serviceNameResolvers = [NSMutableArray array];
        
        self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        self.netServiceBrowser.delegate = self;
        
//        DNSServiceErrorType error;
//        
//        DNSServiceRef ref;
//        
//        /* Issue a Multicast DNS query for the service type meta-query PTR record. */
//        error = DNSServiceQueryRecord(&ref,
//                                      0,  // no flags
//                                      0,  // all network interfaces
//                                      kServiceMetaQueryName,  // meta-query record name
//                                      ns_t_ptr,  // DNS PTR Record
//                                      ns_c_in,  // Internet Class
//                                      MyMetaQueryCallback,  // callback function ptr
//                                      (__bridge void *)(self));  // no context
//        
//        if (error == kDNSServiceErr_NoError) {
//            DNSServiceProcessResult(ref);
//        }
        
        NSString *browseType = @"_services._dns-sd._udp.";
        
        self.searchingTopLevel = true;
        
        [self.netServiceBrowser searchForServicesOfType:browseType inDomain:@""];
    }
    return self;
}

- (void)addServiceWithType:(char[])type domain:(char[])domain interfaceName:(char[])interfaceName
{
    NSString *typeString = [NSString stringWithCString:type encoding:NSASCIIStringEncoding];
    NSString *domainString = [NSString stringWithCString:domain encoding:NSASCIIStringEncoding];
    NSString *interfaceNameString = [NSString stringWithCString:interfaceName encoding:NSASCIIStringEncoding];
    
//    NSLog(@"Type: %@, Domain: %@, Interface: %@", typeString, domainString, interfaceNameString);
    
    ServiceListingTopLevelItem *item = [[ServiceListingTopLevelItem alloc] init];
    [item setType:typeString];
    [item setDomain:domainString];
    
    self.detectedServices = [self.detectedServices arrayByAddingObject:item];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSString *type = [NSString stringWithFormat:@"%@.%@", [service name], [service type]];
    type = [type substringToIndex:[type length]-7];
    
    if([browser isEqual:self.netServiceBrowser]) {
//        self.detectedServices = [self.detectedServices arrayByAddingObject:type];
        
        NameResolverNetServiceBrowser *nameResolver = [[NameResolverNetServiceBrowser alloc] init];
        [nameResolver setDelegate:self];
        [nameResolver setMasterService:service];
        
        ServiceListingTopLevelItem *item = [[ServiceListingTopLevelItem alloc] init];
        [item setType:type];
        [item setMasterService:service];
        
        self.detectedServices = [self.detectedServices arrayByAddingObject:item];
        
        [self.serviceNameResolvers addObject:nameResolver];
        
        [nameResolver searchForServicesOfType:type inDomain:@""];
    } else {
        NSLog(@"%@ %@", [service name], [service type]);
        
        NameResolverNetServiceBrowser *nameResolver = (NameResolverNetServiceBrowser *)browser;
        
        ServiceListingTopLevelItem *item = [self topLevelItemWithMasterService:[nameResolver masterService]];
//        [item setDomain:domainString];
//        [item setResolvedService:service];
        
        if(!item) {
            NSLog(@"Error, no found top level item");
            return;
        }
        
        [item setResolvedNames:[[item resolvedNames] arrayByAddingObject:[service name]]];
        [item setResolvingServices:[[item resolvingServices] arrayByAddingObject:service]];
        
        self.detectedServices = [self.detectedServices arrayByAddingObject:item];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BonjourServiceUpdate" object:nil]];
    }
    
    if(!moreComing) {
//        [browser stop];
        
        if(![browser isEqual:self.netServiceBrowser]) {
//            [self.serviceNameResolvers removeObject:browser];
        }
    }
    
//    if(!moreComing) {
//        if(self.searchingTopLevel) {
//            self.index = 0;
//        }
//        self.searchingTopLevel = false;
//        [self.netServiceBrowser stop];
////        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
////            [self searchTest];
////        }];
//    }
}

- (ServiceListingTopLevelItem *)topLevelItemWithMasterService:(NSNetService *)masterService
{
    for(ServiceListingTopLevelItem *item in self.detectedServices) {
        if([[item masterService] isEqual:masterService]) {
            return item;
        }
    }
    
    return nil;
}

- (void)searchTest
{
    if(self.index >= [self.detectedServices count]) {
        return;
    }
    
    NSString *serviceName = [self.detectedServices objectAtIndex:self.index];
    self.index = self.index+1;
    
    [self.netServiceBrowser searchForServicesOfType:serviceName inDomain:@""];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    NSLog(errorDict);
}

#pragma mark - C Methods

typedef struct { unsigned char c[ 64]; } domainlabel;      // One label: length byte and up to 63 characters.
typedef struct { unsigned char c[256]; } domainname;       // Up to 255 bytes of length-prefixed domainlabels.

void
DNSSD_API MetaQueryCallback(DNSServiceRef service, DNSServiceFlags flags, uint32_t interfaceID, DNSServiceErrorType error,
                              const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, void * context)
{
    printf(fullname);
}

void
DNSSD_API MyMetaQueryCallback(DNSServiceRef service, DNSServiceFlags flags, uint32_t interfaceID, DNSServiceErrorType error,
                              const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, void * context)
{
#if defined(_APPLE_)
#pragma unused(service)
#pragma unused(rrclass)
#pragma unused(ttl)
#pragma unused(context)
#endif
    
    assert(strcmp(fullname, kServiceMetaQueryName) == 0);
    
    DNSQuerier *self = (__bridge DNSQuerier *)context;
    
//    printf("%s", rdata);
    
    if (error == kDNSServiceErr_NoError) {
        
        char interfaceName[MAX_DOMAIN_NAME];
        char domain[MAX_DOMAIN_NAME];
        char type[MAX_DOMAIN_NAME];
        
        memset(interfaceName, 0x00, MAX_DOMAIN_NAME);
        memset(domain, 0x00, MAX_DOMAIN_NAME);
        memset(type, 0x00, MAX_DOMAIN_NAME);
        /* Get the type and domain from the discovered PTR record. */
        MyGetTypeAndDomain(rdata, rdlen, type, domain);
        
        /* Convert an interface index into a BSD-style interface name. */
        [self convertInterfaceIndexToName:interfaceID withInterfaceName:interfaceName];
        
        if (flags & kDNSServiceFlagsAdd) {
            [self addServiceWithType:type domain:domain interfaceName:interfaceName];
            
            DNSServiceErrorType error;
            
            DNSServiceRef ref;
            
            /* Issue a Multicast DNS query for the service type meta-query PTR record. */
            error = DNSServiceQueryRecord(&ref,
                                          0,  // no flags
                                          0,  // all network interfaces
                                          type,  // meta-query record name
                                          ns_t_ptr,  // DNS PTR Record
                                          ns_c_in,  // Internet Class
                                          MetaQueryCallback,  // callback function ptr
                                          (__bridge void *)(self));  // no context
            
            if (error == kDNSServiceErr_NoError) {
                DNSServiceProcessResult(ref);
            }
        } else {
            /* REMOVE is only called when a network interface is disabled or if the record
             expires from the cache.  For network efficiency reasons, clients do not send
             goodbye packets for meta-query PTR records when deregistering a service.  */
            fprintf(stderr, "REMOVE   %-28s  %-14s %s\n", type, domain, interfaceName);
        }
    } else {
        fprintf(stderr, "MyQueryRecordCallback returned %d\n", error);
    }
}

- (char *)convertInterfaceIndexToName:(uint32_t)interface withInterfaceName:(char *)interfaceName
{
    assert(interfaceName != NULL);
    
    if      (interface == 0)          strcpy(interfaceName,   "all");   // All active network interfaces.
    else if (interface == 0xFFFFFFFF) strcpy(interfaceName, "local");   // Only available locally on this machine.
    else if_indextoname(interface, interfaceName);                      // Converts interface index to interface name.
    
    return interfaceName;
}

/* MyConvertDomainLabelToCString() converts a DNS label into a C string.
 A DNS label string is formatted like "\003com".  The converted string
 would look like "com." */

char*
MyConvertDomainLabelToCString(const domainlabel *const label, char *ptr)
{
    const unsigned char *      src = label->c;      // Domain label we're reading.
    const unsigned char        len = *src++;        // Read length of this (non-null) label.
    const unsigned char *const end = src + len;     // Work out where the label ends.
    
    assert(label != NULL);
    assert(ptr   != NULL);
    
    if (len > MAX_DOMAIN_LABEL) return(NULL);       // If illegal label, abort.
    while (src < end) {                             // While we have characters in the label.
        unsigned char c = *src++;
        if (c == '.' || c == '\\')                  // If character is a dot or the escape character
            *ptr++ = '\\';                          // Output escape character.
        else if (c <= ' ') {                        // If non-printing ascii, output decimal escape sequence.
            *ptr++ = '\\';
            *ptr++ = (char)  ('0' + (c / 100)     );
            *ptr++ = (char)  ('0' + (c /  10) % 10);
            c      = (unsigned char)('0' + (c      ) % 10);
        }
        *ptr++ = (char)c;                           // Copy the character.
    }
    *ptr = 0;                                       // Null-terminate the string
    return(ptr);                                    // and return.
}


/* MyConvertDomainNameToCString() converts a DNS name string into a C string.
 A DNS name string is formated like "\003www\005apple\003com\0".  The converted
 string would look like "www.apple.com".  If the DNS name contains a period "." or
 a backslash "\", then those characters will be escaped with backslash characters,
 as in "\." and "\\".  Note: To guarantee that there will be no possible overrun,
 "ptr" must be at least kDNSServiceMaxDomainName (1005 bytes) */

char*
MyConvertDomainNameToCString(const domainname *const name, char *ptr)
{
    const unsigned char *src         = name->c;                     // Domain name we're reading.
    const unsigned char *const max   = name->c + MAX_DOMAIN_NAME;   // Maximum that's valid.
    
    assert(name != NULL);
    assert(ptr  != NULL);
    
    if (*src == 0) *ptr++ = '.';                                    // Special case: For root, just write a dot.
    
    while (*src) {                                                  // While more characters in the domain name.
        if (src + 1 + *src >= max) return(NULL);
        ptr = MyConvertDomainLabelToCString((const domainlabel *)src, ptr);
        if (!ptr) return(NULL);
        src += 1 + *src;
        *ptr++ = '.';                                               // Write the dot after the label.
    }
    
    *ptr++ = 0;                                                     // Null-terminate the string
    return(ptr);                                                    // and return.
}

/* The DNSServiceQueryRecord callback returns a DNS PTR record with rdata formatted like:
 
 \005_http\004_tcp\005local\0
 
 MyGetTypeAndDomain() takes the rdata and splits it up into two C strings which correspond to the
 "type" and "domain" of a service.  These strings could potentially be passed to a function
 like DNSServiceBrowse().  Assuming the example rdata above, this function would return "_http._tcp."
 as the "type", and "local." for the "domain". */

void MyGetTypeAndDomain(const void * rdata, uint16_t rdlen, char * type, char * domain)
{
    unsigned char *cursor;
    unsigned char *start;
    unsigned char *end;
    
    assert(rdata  != NULL);
    assert(rdlen  != 0);
    assert(type   != NULL);
    assert(domain != NULL);
    
    start = (unsigned char*)malloc(rdlen);
    assert(start != NULL);
    memcpy(start, rdata, rdlen);
    
    end = start + rdlen;
    cursor = start;
    if ((*cursor == 0) || (*cursor >= 64)) goto exitWithError;
    cursor += 1 + *cursor;                                       // Move to the start of the second DNS label.
    if (cursor >= end) goto exitWithError;
    if ((*cursor == 0) || (*cursor >= 64)) goto exitWithError;
    cursor += 1 + *cursor;                                       // Move to the start of the thrid DNS label.
    if (cursor >= end) goto exitWithError;
    
    /* Take everything from start of third DNS label until end of DNS name and call that the "domain". */
    if (MyConvertDomainNameToCString((const domainname *)cursor, domain) == NULL) goto exitWithError;
    *cursor = 0;                                                 // Set the length byte of the third label to zero.
    
    /* Take the first two DNS labels and call that the "type". */
    if (MyConvertDomainNameToCString((const domainname *)start, type) == NULL) goto exitWithError;
    free(start);
    return;
    
exitWithError:
    fprintf(stderr, "Invalid DNS name string\n");
    free(start);
}

@end
