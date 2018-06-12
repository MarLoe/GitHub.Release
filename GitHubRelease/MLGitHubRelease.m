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
#define λ(decl, error, expr) (^(decl, error) { return (expr); })


#pragma mark - Private model interfaces


static id map(id collection, NSErrorRef* error, id (^f)(id value, NSErrorRef* error)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) {
            id obj = f(x, error);
            if (obj == nil) {
                return nil;
            }
            [result addObject:obj];
        }
    }
    else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) {
            id obj = f([collection objectForKey:key], error);
            if (obj == nil) {
                return nil;
            }
            result[key] = obj;
        }
    }
    return result;
}


#pragma mark - JSON serialization

MLGitHubReleases *_Nullable MLGitHubReleaseFromData(NSData *data, NSErrorRef* error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        if (json == nil) {
            return nil;
        }
        return map(json, error, λ(id x, NSErrorRef* e,[MLGitHubRelease fromJSONDictionary:x error:e]));
    } @catch (NSException *exception) {
        if (error != nil) {
            *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        }
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
        properties = [super propertiesWithDictionary:@{
                                                       @"assets_url":           @"assetsURL",
                                                       @"upload_url":           @"uploadURL",
                                                       @"html_url":             @"htmlURL",
                                                       @"tag_name":             @"tagName",
                                                       @"target_commitish":     @"targetCommitish",
                                                       @"name":                 @"name",
                                                       @"node_id":              @"nodeId",
                                                       @"draft":                @"isDraft",
                                                       @"author":               @"author",
                                                       @"prerelease":           @"isPrerelease",
                                                       @"created_at":           @"createdAt",
                                                       @"published_at":         @"publishedAt",
                                                       @"assets":               @"assets",
                                                       @"tarball_url":          @"tarballURL",
                                                       @"zipball_url":          @"zipballURL",
                                                       @"body":                 @"body",
                                                       }];
    });
    return properties;
}


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    return dict ? [[MLGitHubRelease alloc] initWithJSONDictionary:dict error:error] : nil;
}


- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error
{
    if (self = [super initWithJSONDictionary:dict error:error]) {
        @try {
            _author = [MLGitHubUploader fromJSONDictionary:(id)_author error:error];
            _assets = map(_assets, error, λ(id x, NSErrorRef* e, [MLGitHubAsset fromJSONDictionary:x error:e]));
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


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], _name];
}

@end
