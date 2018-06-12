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

@interface MLGitHubObject (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
@end


@interface MLGitHubRelease (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
@end


@interface MLGitHubAsset (JSONConversion)
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nullable)dict error:(NSError **)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
@end


@interface MLGitHubUploader (JSONConversion)
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError **)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *)dict error:(NSError **)error;
@end
