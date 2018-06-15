//
//  MLGitHibAsset.h
//  GitHubRelease
//
//  Created by Martin Løbger on 29/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGitHubObject.h"
#import "MLGitHubUploader.h"

@class MLGitHubAsset;

typedef NSArray<MLGitHubAsset *> MLGitHubAssets;

typedef void (^MLGitHubAssetProgressHandler) (NSURLResponse * _Nullable response, NSProgress* _Nullable progress);
typedef void (^MLGitHubAssetCompletionHandler) (NSURLResponse * _Nullable response, NSProgress* _Nullable progress, NSURL * _Nullable location, NSError * _Nullable error);


@interface MLGitHubAsset : MLGitHubObject

#pragma mark - GitHub properties

@property (nonatomic, nullable, copy)   NSString*                   name;
@property (nonatomic, nullable, copy)   NSString*                   label;
@property (nonatomic, nullable, strong) MLGitHubUploader*           uploader;
@property (nonatomic, nullable, copy)   NSString*                   contentType;
@property (nonatomic, nullable, copy)   NSString*                   state;
@property (nonatomic, assign)           NSInteger                   size;
@property (nonatomic, assign)           NSInteger                   downloadCount;
@property (nonatomic, nullable, copy)   NSDate*                     createdAt;
@property (nonatomic, nullable, copy)   NSDate*                     updatedAt;
@property (nonatomic, nullable, copy)   NSURL*                      browserDownloadURL;


#pragma mark - MLGitHubAsset methods

/**
 @brief         Download the asset using NSURLSessionDownloadTask configured with the default NSURLSessionConfiguration configuration.
 @discussion    The asset is downloaded to disk and can on success be found at "location" of the completionHandler.
 @remarks       Set the delegate of the asset to follow the download progress.
 @param         completionHandler Called on completion.
 */
- (void)downloadWithProgressHandler:(MLGitHubAssetProgressHandler)progressHandler andCompletionHandler:(MLGitHubAssetCompletionHandler)completionHandler;
//- (void)downloadWithCompletionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end


