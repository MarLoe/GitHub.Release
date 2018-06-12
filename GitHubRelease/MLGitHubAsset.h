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


@interface MLGitHubAsset : MLGitHubObject

@property (nonatomic, nullable, copy)   NSString*           name;
@property (nonatomic, nullable, copy)   NSString*           label;
@property (nonatomic, nullable, strong) MLGitHubUploader*   uploader;
@property (nonatomic, nullable, copy)   NSString*           contentType;
@property (nonatomic, nullable, copy)   NSString*           state;
@property (nonatomic, assign)           NSInteger           size;
@property (nonatomic, assign)           NSInteger           downloadCount;
@property (nonatomic, nullable, copy)   NSDate*             createdAt;
@property (nonatomic, nullable, copy)   NSDate*             updatedAt;
@property (nonatomic, nullable, copy)   NSURL*              browserDownloadURL;

- (void)downloadWithCompletionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end


