// MLGitHubRelease.h

// To parse this JSON:
//
//   NSError *error;
//   MLGitHubRelease *release = MLGitHubReleaseFromJSON(json, NSUTF8Encoding, &error);

#import <Foundation/Foundation.h>

@class MLGitHubRelease;
@class MLGitHubAsset;
@class MLGitHubUploader;


typedef NSArray<MLGitHubRelease *> MLGitHubReleases;

#pragma mark - Top-level marshaling functions

typedef NSError* _Nullable NSErrorRef;

MLGitHubReleases *_Nullable MLGitHubReleaseFromData(NSData * _Nonnull data, NSErrorRef* _Nullable error);
MLGitHubReleases *_Nullable MLGitHubReleaseFromJSON(NSString * _Nonnull json, NSStringEncoding encoding, NSErrorRef* _Nullable error);

#pragma mark - Object interfaces

@interface MLGitHubRelease : NSObject
@property (nonatomic, nullable, copy)   NSString *url;
@property (nonatomic, nullable, copy)   NSString *assetsURL;
@property (nonatomic, nullable, copy)   NSString *uploadURL;
@property (nonatomic, nullable, copy)   NSString *htmlURL;
@property (nonatomic, assign)           NSInteger identifier;
@property (nonatomic, nullable, copy)   NSString *tagName;
@property (nonatomic, nullable, copy)   NSString *targetCommitish;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, assign)           BOOL isDraft;
@property (nonatomic, nullable, strong) MLGitHubUploader *author;
@property (nonatomic, assign)           BOOL isPrerelease;
@property (nonatomic, nullable, copy)   NSString *createdAt;
@property (nonatomic, nullable, copy)   NSString *publishedAt;
@property (nonatomic, nullable, copy)   NSArray<MLGitHubAsset *> *assets;
@property (nonatomic, nullable, copy)   NSString *tarballURL;
@property (nonatomic, nullable, copy)   NSString *zipballURL;
@property (nonatomic, nullable, copy)   NSString *body;
@end


