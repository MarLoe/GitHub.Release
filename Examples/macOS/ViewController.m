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
            // Suppress this alert from now on
            [userDefaults setObject:releaseInfo.name forKey:@"skip"];
        }
        
        switch (returnCode) {
            case NSModalResponseView:
                [[NSWorkspace sharedWorkspace] openURL:releaseInfo.htmlURL];
                break;
            case NSModalResponseDownload:
                [asset downloadWithCompletionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    // TODO: Save asset and do what needs to be done
                }];
                break;
            default:
                break;
        }
    }];
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker *)sender failedWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [[NSAlert alertWithError:error] runModal];
}

@end
