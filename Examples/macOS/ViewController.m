//
//  ViewController.m
//  Example.macOS
//
//  Created by Martin Løbger on 12/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "ViewController.h"

static const NSModalResponse NSModalResponseView        = 1001;
static const NSModalResponse NSModalResponseDownload    = 1002;

@interface ViewController()
@property (weak) IBOutlet NSImageView*  imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSBundle* prefPaneBundle = [NSBundle bundleForClass:self.class];
    _version = [prefPaneBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    // Try setting _version to something old
    _version = @"0.1.0";
    
    self.releaseChecker = [[MLGitHubReleaseChecker alloc] initWithUser:@"MarLoe" andProject:@"GitHub.Release"];
    _releaseChecker.delegate = self;
    [_releaseChecker checkReleaseWithName:_version];
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


#pragma mark - GitHubReleaseCheckerDelegate

- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSLog(@"%@", releaseInfo.url.absoluteString);
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundNewReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults stringForKey:@"skip"] isEqualToString:releaseInfo.name]) {
        // The user has opted out of more alerts regarding this version.
        return;
    }
    
    if (releaseInfo.htmlURL == nil) {
        return;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Asset.png"];
    MLGitHubAsset* asset = [releaseInfo.assets filteredArrayUsingPredicate:predicate].firstObject;
    
    NSAlert* alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.showsSuppressionButton = YES; // Uses default checkbox title
    alert.messageText = NSLocalizedString(@"A new version is available", -);
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                             releaseInfo.name,
                             sender.currentRelease.name
                             ];
    [alert addButtonWithTitle:NSLocalizedString(@"View", -)].tag = NSModalResponseView;
    if (asset != nil) {
        [alert addButtonWithTitle:NSLocalizedString(@"Download", -)].tag = NSModalResponseDownload;
    }
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", -)].tag = NSModalResponseCancel;
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (alert.suppressionButton.state == NSOnState) {
            // Suppress this alert from now on (for this release only)
            [userDefaults setObject:releaseInfo.name forKey:@"skip"];
        }
        
        switch (returnCode) {
            case NSModalResponseView: {
                [[NSWorkspace sharedWorkspace] openURL:releaseInfo.htmlURL];
                break;
            }
            case NSModalResponseDownload: {
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSString* downloadFolder = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES).firstObject;
                NSURL* downloadUrl = [NSURL fileURLWithPathComponents:@[downloadFolder, asset.name]];
                
                // Find unique file name
                for (int i = 1; [fileManager fileExistsAtPath:downloadUrl.path]; i++) {
                    NSString* assetName = [[NSString stringWithFormat:@"%@ (%i)", [asset.name stringByDeletingPathExtension], i] stringByAppendingPathExtension:[asset.name pathExtension]];
                    downloadUrl = [NSURL fileURLWithPathComponents:@[downloadFolder, assetName]];
                }
                // Create a placeholde until we are done downloading.
                [fileManager createFileAtPath:downloadUrl.path contents:nil attributes:nil];
                
                [asset downloadWithProgressHandler:^(NSURLResponse* _Nullable response, NSProgress* _Nullable progress) {
                    NSLog(@"Downloading %@: %lld / %lld (%i%%)",asset.name, progress.completedUnitCount, progress.totalUnitCount, (int)(100.0 * progress.fractionCompleted));
                    if (progress.completedUnitCount == 0) {
                        // This part will activate progress in "Downloads stack" in the dock
                        progress.kind = NSProgressKindFile;
                        [progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
                        [progress setUserInfoObject:downloadUrl forKey:NSProgressFileURLKey];
                        [progress publish];
                    }
                } andCompletionHandler:^(NSURLResponse* _Nullable response, NSProgress* _Nullable progress, NSURL* _Nullable location, NSError* _Nullable error) {
                    NSLog(@"%@", error ?: location);
                    if (error == nil && [response isKindOfClass:NSHTTPURLResponse.class]) {
                        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                        if (httpResponse.statusCode != 200) {
                            error = [NSError errorWithDomain:NSURLErrorDomain
                                                        code:httpResponse.statusCode
                                                    userInfo:@{
                                                               NSLocalizedDescriptionKey : [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]
                                                               }];
                        }
                    }
                    
                    if (error == nil && location!= nil) {
                        [fileManager replaceItemAtURL:downloadUrl
                                        withItemAtURL:location
                                       backupItemName:nil
                                              options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                     resultingItemURL:nil
                                                error:&error];
                    }
                    
                    if (error == nil) {
                        // Make the "Downloads stack" bounce
                        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.DownloadFileFinished" object:downloadUrl.path];
                        
                        [self.imageView performSelectorOnMainThread:@selector(setImage:)
                                                         withObject:[[NSImage alloc] initWithContentsOfURL:downloadUrl]
                                                      waitUntilDone:NO];
                    }
                    
                    if (error != nil) {
                        // In case of error, remove our placeholder file.
                        [fileManager removeItemAtURL:downloadUrl error:nil];
                        [[NSAlert alertWithError:error] runModal];
                    }
                    
                    [progress unpublish]; // End "Downloads stack" progress
                }];
                break;
            }
            default: {
                break;
            }
        }
    }];
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender failedWithError:(NSError*)error
{
    NSLog(@"%@", error);
    [[NSAlert alertWithError:error] runModal];
}

@end
