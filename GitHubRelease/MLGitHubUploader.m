//
//  MLGitHubUploader.m
//  GitHubRelease
//
//  Created by Martin Løbger on 18/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubUploader.h"

@implementation MLGitHubUploader
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
                                                    @"login": @"login",
                                                    @"id": @"identifier",
                                                    @"avatar_url": @"avatarURL",
                                                    @"gravatar_id": @"gravatarID",
                                                    @"url": @"url",
                                                    @"html_url": @"htmlURL",
                                                    @"followers_url": @"followersURL",
                                                    @"following_url": @"followingURL",
                                                    @"gists_url": @"gistsURL",
                                                    @"starred_url": @"starredURL",
                                                    @"subscriptions_url": @"subscriptionsURL",
                                                    @"organizations_url": @"organizationsURL",
                                                    @"repos_url": @"reposURL",
                                                    @"events_url": @"eventsURL",
                                                    @"received_events_url": @"receivedEventsURL",
                                                    @"type": @"type",
                                                    @"site_admin": @"siteAdmin",
                                                    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MLGitHubUploader alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    [super setValue:value forKey:MLGitHubUploader.properties[key]];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MLGitHubUploader.properties.allValues] mutableCopy];
    
    // Rewrite property names that differ in JSON
    for (id jsonName in MLGitHubUploader.properties) {
        id propertyName = MLGitHubUploader.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }
    
    return dict;
}
@end
