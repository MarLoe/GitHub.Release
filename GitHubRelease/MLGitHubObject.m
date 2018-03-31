//
//  MLGitHubObject.m
//  GitHubRelease
//
//  Created by Martin Løbger on 30/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubObject.h"
#import "MLGitHubError.h"
#import <objc/runtime.h>

@implementation MLGitHubObject

- (NSDictionary<NSString *, NSString *> *)properties
{
    NSAssert(NO, @"Please override properties");
    return nil;
}


- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    key = self.properties[key];
    
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    if (property == NULL) {
        @throw [NSError errorWithDomain:GitHubReleaseCheckerErrorDomain
                                   code:GitHubReleaseCheckerErrorUnknownProperty
                               userInfo:@{
                                          NSLocalizedDescriptionKey: @"Unknown property"
                                          }];
    }
    const char * type = property_getAttributes(property);
    if (strstr(type, "NSURL") != NULL) {
        value = [NSURL URLWithString:value];
    }
    else if (strstr(type, "NSDate") != NULL) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
        value = [dateFormatter dateFromString:value];
    }
    
    [super setValue:value forKey:key];
}

@end
