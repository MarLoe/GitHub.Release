//
//  MLGitHibAsset.m
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"
#import "MLGitHubPrivate.h"


@implementation MLGitHubAsset

- (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{
                       @"url":                  @"url",
                       @"id":                   @"identifier",
                       @"name":                 @"name",
                       @"label":                @"label",
                       @"uploader":             @"uploader",
                       @"content_type":         @"contentType",
                       @"state":                @"state",
                       @"size":                 @"size",
                       @"download_count":       @"downloadCount",
                       @"created_at":           @"createdAt",
                       @"updated_at":           @"updatedAt",
                       @"browser_download_url": @"browserDownloadURL",
                       };
    });
    return properties;
}


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MLGitHubAsset alloc] initWithJSONDictionary:dict] : nil;
}


- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _uploader = [MLGitHubUploader fromJSONDictionary:(id)_uploader];
    }
    return self;
}

@end
