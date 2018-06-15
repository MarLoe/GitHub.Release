//
//  NSURLSession+Progress.h
//  GitHubRelease
//
//  Created by GN Hearing on 14/06/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGitHubAsset.h"

@interface NSURLSession (Progress)

@property (nonatomic, strong) MLGitHubAssetProgressHandler progressHandler;
@property (nonatomic, strong) MLGitHubAssetCompletionHandler completionHandler;

@property (nonatomic, strong) NSProgress* progress;

@end
