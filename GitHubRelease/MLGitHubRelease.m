
// MLGitHubRelease.m

#import "MLGitHubRelease.h"
#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface MLGitHubRelease (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end



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

NSData *_Nullable MLGitHubReleaseToData(MLGitHubReleases *release, NSError **error)
{
    @try {
        id json = map(release, λ(id x, [x JSONDictionary]));
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable MLGitHubReleaseToJSON(MLGitHubReleases *release, NSStringEncoding encoding, NSError **error)
{
    NSData *data = MLGitHubReleaseToData(release, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation MLGitHubRelease

+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
                                                    @"url": @"url",
                                                    @"assets_url": @"assetsURL",
                                                    @"upload_url": @"uploadURL",
                                                    @"html_url": @"htmlURL",
                                                    @"id": @"identifier",
                                                    @"tag_name": @"tagName",
                                                    @"target_commitish": @"targetCommitish",
                                                    @"name": @"name",
                                                    @"draft": @"isDraft",
                                                    @"author": @"author",
                                                    @"prerelease": @"isPrerelease",
                                                    @"created_at": @"createdAt",
                                                    @"published_at": @"publishedAt",
                                                    @"assets": @"assets",
                                                    @"tarball_url": @"tarballURL",
                                                    @"zipball_url": @"zipballURL",
                                                    @"body": @"body",
                                                    };
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

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    [super setValue:value forKey:MLGitHubRelease.properties[key]];
}

@end




NS_ASSUME_NONNULL_END
