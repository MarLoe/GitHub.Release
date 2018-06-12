//
//  MLGitHubUploader.m
//  GitHubRelease
//
//  Created by Martin Løbger on 18/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubUploader.h"
#import "MLGitHubPrivate.h"

@implementation MLGitHubUploader


- (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{
                       @"login":                @"login",
                       @"id":                   @"identifier",
                       @"avatar_url":           @"avatarURL",
                       @"gravatar_id":          @"gravatarID",
                       @"url":                  @"url",
                       @"html_url":             @"htmlURL",
                       @"followers_url":        @"followersURL",
                       @"following_url":        @"followingURL",
                       @"gists_url":            @"gistsURL",
                       @"starred_url":          @"starredURL",
                       @"subscriptions_url":    @"subscriptionsURL",
                       @"organizations_url":    @"organizationsURL",
                       @"repos_url":            @"reposURL",
                       @"events_url":           @"eventsURL",
                       @"received_events_url":  @"receivedEventsURL",
                       @"type":                 @"type",
                       @"site_admin":           @"siteAdmin",
                       };
    });
    return properties;
}


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    return dict ? [[MLGitHubUploader alloc] initWithJSONDictionary:dict error:error] : nil;
}


- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    if (self = [super initWithJSONDictionary:dict error:error]) {
    }
    return self;
}

@end
