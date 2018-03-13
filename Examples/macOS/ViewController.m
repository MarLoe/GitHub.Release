//
//  ViewController.m
//  Example.macOS
//
//  Created by Martin Løbger on 12/03/2018.
//  Copyright © 2018 Martin Løbger. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSBundle* prefPaneBundle = [NSBundle bundleForClass:self.class];
    _version = [prefPaneBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    // Try setting _version to something old
    //_version = @"0.1.0";

    self.releaseChecker = [[GitHubReleaseChecker alloc] initWithUser:@"MarLoe" andProject:@"GitHub.Release"];
    _releaseChecker.delegate = self;
    [_releaseChecker checkRelease:_version];
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - GitHubReleaseCheckerDelegate

- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundReleaseInfo:(NSDictionary*)releaseInfo
{
    NSLog(@"%@", releaseInfo);
}


- (void)gitHubReleaseChecker:(GitHubReleaseChecker*)sender checkRelease:(NSString*)releaseName foundNewReleaseInfo:(NSDictionary*)releaseInfo
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults stringForKey:@"skip"] isEqualToString:releaseInfo[kGitHubReleaseCheckerNameKey]]) {
        // The user has opted out of more alerts regarding this version.
        return;
    }

    NSString* repoUrl = releaseInfo[kGitHubReleaseCheckerHtmlUrlKey];
    if (repoUrl.length == 0) {
        return;
    }

    NSAlert* alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.showsSuppressionButton = YES; // Uses default checkbox title
    alert.messageText = NSLocalizedString(@"A new version is available", -);
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                             releaseInfo[kGitHubReleaseCheckerNameKey],
                             releaseName
                             ];
    [alert addButtonWithTitle:NSLocalizedString(@"View", -)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", -)].tag = NSModalResponseCancel;
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (alert.suppressionButton.state == NSOnState) {
            // Suppress this alert from now on
            [userDefaults setObject:releaseInfo[kGitHubReleaseCheckerNameKey] forKey:@"skip"];
        }
        
        if (returnCode == NSModalResponseCancel) {
            return;
        }
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:repoUrl]];
    }];
}


- (void)gitHubReleaseChecker:(GitHubReleaseChecker *)sender checkRelease:(NSString *)releaseName failedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
