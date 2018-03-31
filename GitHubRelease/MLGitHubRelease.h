//
//  MLGitHubRelease.h
//  GitHubRelease
//
//  Created by Martin Løbger on 30/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGitHubObject.h"
#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"

@class MLGitHubRelease;

typedef NSArray<MLGitHubRelease *> MLGitHubReleases;

#pragma mark - Top-level marshaling functions

typedef NSError* _Nullable NSErrorRef;

MLGitHubReleases *_Nullable MLGitHubReleaseFromData(NSData * _Nonnull data, NSErrorRef* _Nullable error);
MLGitHubReleases *_Nullable MLGitHubReleaseFromJSON(NSString * _Nonnull json, NSStringEncoding encoding, NSErrorRef* _Nullable error);

#pragma mark - Object interfaces

@interface MLGitHubRelease : MLGitHubObject

@property (nonatomic, nullable, copy)   NSURL*              url;
@property (nonatomic, nullable, copy)   NSURL*              assetsURL;
@property (nonatomic, nullable, copy)   NSURL*              uploadURL;
@property (nonatomic, nullable, copy)   NSURL*              htmlURL;
@property (nonatomic, assign)           NSInteger           identifier;
@property (nonatomic, nullable, copy)   NSString*           tagName;
@property (nonatomic, nullable, copy)   NSString*           targetCommitish;
@property (nonatomic, nullable, copy)   NSString*           name;
@property (nonatomic, assign)           BOOL                isDraft;
@property (nonatomic, nullable, strong) MLGitHubUploader*   author;
@property (nonatomic, assign)           BOOL                isPrerelease;
@property (nonatomic, nullable, copy)   NSDate*             createdAt;
@property (nonatomic, nullable, copy)   NSDate*             publishedAt;
@property (nonatomic, nullable, copy)   NSArray<MLGitHubAsset *>*     assets;
@property (nonatomic, nullable, copy)   NSURL*              tarballURL;
@property (nonatomic, nullable, copy)   NSURL*              zipballURL;
@property (nonatomic, nullable, copy)   NSString*           body;

@end


