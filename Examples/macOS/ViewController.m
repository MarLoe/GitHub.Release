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
    NSLog(@"%@", releaseInfo);
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker*)sender foundNewReleaseInfo:(MLGitHubRelease*)releaseInfo
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults stringForKey:@"skip"] isEqualToString:releaseInfo.name]) {
        // The user has opted out of more alerts regarding this version.
        return;
    }

    NSString* repoUrl = releaseInfo.htmlURL;
    if (repoUrl.length == 0) {
        return;
    }

    NSAlert* alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.showsSuppressionButton = YES; // Uses default checkbox title
    alert.messageText = NSLocalizedString(@"A new version is available", -);
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"Version %@ is available. You are currently running %@", -),
                             releaseInfo.name,
                             sender.currentRelease.name
                             ];
    [alert addButtonWithTitle:NSLocalizedString(@"View", -)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", -)].tag = NSModalResponseCancel;
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (alert.suppressionButton.state == NSOnState) {
            // Suppress this alert from now on
            [userDefaults setObject:releaseInfo.name forKey:@"skip"];
        }
        
        if (returnCode == NSModalResponseCancel) {
            return;
        }
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:repoUrl]];
    }];
}


- (void)gitHubReleaseChecker:(MLGitHubReleaseChecker *)sender failedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
