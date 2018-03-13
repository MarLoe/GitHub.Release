//
//  MLGitHibAsset.m
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"

@implementation MLGitHubAsset
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
                                                    @"url": @"url",
                                                    @"id": @"identifier",
                                                    @"name": @"name",
                                                    @"label": @"label",
                                                    @"uploader": @"uploader",
                                                    @"content_type": @"contentType",
                                                    @"state": @"state",
                                                    @"size": @"size",
                                                    @"download_count": @"downloadCount",
                                                    @"created_at": @"createdAt",
                                                    @"updated_at": @"updatedAt",
                                                    @"browser_download_url": @"browserDownloadURL",
                                                    };
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

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    [super setValue:value forKey:MLGitHubAsset.properties[key]];
}


@end
