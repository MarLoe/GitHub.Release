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

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    if (self = [super init]) {
        @try {
            [self setValuesForKeysWithDictionary:dict];
        }
        @catch (NSError* e) {
            if (error != nil) {
                *error = e;
            }
            return nil;
        }
    }
    return self;
}


- (NSDictionary<NSString *, NSString *> *)properties
{
    NSLog(@"ERROR: Please override properties");
    return [self propertiesWithDictionary:nil];
}

- (NSDictionary<NSString *, NSString *> *)propertiesWithDictionary:(NSDictionary*)dictionary
{
    NSMutableDictionary* mutableProperties = @{
                                               @"id":                   @"identifier",
                                               @"node_id":              @"nodeId",
                                               @"url":                  @"url",
                                               }.mutableCopy;
    [mutableProperties addEntriesFromDictionary:dictionary];
    return [mutableProperties copy];
}



- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    NSString* propertName = self.properties[key];
    
    objc_property_t property = class_getProperty([self class], propertName.UTF8String);
    if (property == NULL) {
        @throw [NSError errorWithDomain:GitHubReleaseCheckerErrorDomain
                                   code:GitHubReleaseCheckerErrorUnknownProperty
                               userInfo:@{
                                          NSLocalizedDescriptionKey: @"Error loading GitHub information",
                                          NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"Unknown property: %@.%@", NSStringFromClass([self class]), key],
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
    
    [super setValue:value forKey:propertName];
}

@end
