//
//  MLGitHubPrivate.h
//  GitHubRelease
//
//  Created by Martin Løbger on 30/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGitHubRelease.h"
#import "MLGitHubAsset.h"
#import "MLGitHubUploader.h"

@interface MLGitHubRelease (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
@end


@interface MLGitHubAsset (JSONConversion)
+ (instancetype _Nonnull )fromJSONDictionary:(NSDictionary *_Nullable)dict;
@end


@interface MLGitHubUploader (JSONConversion)
+ (instancetype _Nullable )fromJSONDictionary:(NSDictionary *_Nonnull)dict;
@end
