//
//  MLGitHubRelease.m
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "MLGitHubRelease.h"
#import "MLGitHubObject.h"
#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"
#import "MLGitHubPrivate.h"


// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })


#pragma mark - Private model interfaces


static id map(id collection, id (^f)(id value)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) [result addObject:f(x)];
    } else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
    }
    return result;
}


#pragma mark - JSON serialization

MLGitHubReleases *_Nullable MLGitHubReleaseFromData(NSData *data, NSErrorRef* error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : map(json, λ(id x, [MLGitHubRelease fromJSONDictionary:x]));
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}


MLGitHubReleases *_Nullable MLGitHubReleaseFromJSON(NSString *json, NSStringEncoding encoding, NSErrorRef* error)
{
    return MLGitHubReleaseFromData([json dataUsingEncoding:encoding], error);
}


@implementation MLGitHubRelease

- (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{
                       @"url":                 @"url",
                       @"assets_url":          @"assetsURL",
                       @"upload_url":          @"uploadURL",
                       @"html_url":            @"htmlURL",
                       @"id":                  @"identifier",
                       @"tag_name":            @"tagName",
                       @"target_commitish":    @"targetCommitish",
                       @"name":                @"name",
                       @"draft":               @"isDraft",
                       @"author":              @"author",
                       @"prerelease":          @"isPrerelease",
                       @"created_at":          @"createdAt",
                       @"published_at":        @"publishedAt",
                       @"assets":              @"assets",
                       @"tarball_url":         @"tarballURL",
                       @"zipball_url":         @"zipballURL",
                       @"body":                @"body",
                       };
    });
    return properties;
}


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MLGitHubRelease alloc] initWithJSONDictionary:dict] : nil;
}


- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _author = [MLGitHubUploader fromJSONDictionary:(id)_author];
        _assets = map(_assets, λ(id x, [MLGitHubAsset fromJSONDictionary:x]));
    }
    return self;
}



@end
