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
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
- (NSDictionary<NSString *, NSString *> *_Nonnull)propertiesWithDictionary:(NSDictionary*_Nonnull)dictionary;
@end


@interface MLGitHubRelease (JSONConversion)
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
@end


@interface MLGitHubAsset (JSONConversion)
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nullable)dict error:(NSError *_Nullable*_Nullable)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
@end


@interface MLGitHubUploader (JSONConversion)
+ (instancetype _Nullable)fromJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
- (instancetype _Nullable)initWithJSONDictionary:(NSDictionary *_Nonnull)dict error:(NSError *_Nullable*_Nullable)error;
@end
