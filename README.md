# ![AppIcon](Examples/macOS/Assets.xcassets/AppIcon.appiconset/icon64.png) GitHub.Release

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/MarLoe/GitHub.Release/blob/master/LICENSE)

Check your GitHub repo for new releases from within your software.

## Introduction

Using GitHub to host your software?
Want to check for new releases?
Use GitHubRelease to check if a new release has been published.
Prereleases and drafts can be opted in via configuration.

## Installing

GitHub.Release is a framework that can be integrated into your project.
It supports installation via [cocoapods](https://cocoapods.org/).

## Building

Use Xcode 9 or later.

## Usage

Make sure you have added the GitHub.Release framework to your project. Using cocoapods does this automatically for you.

Import the framework header

```Objective-C
#import <GitHubRelease/GitHubRelease.h>
```

Now somewhere appropriate in your source code add these lines to check for new releases.

```Objective-C
GitHubReleaseChecker* releaseChecker = [[GitHubReleaseChecker alloc] initWithUser:@"MarLoe"
                                                                       andProject:@"GitHub.Release"];
releaseChecker.delegate = self;
[releaseChecker checkRelease:self.version];
```

Remember to change "MarLoe" and "GitHub.Release" to your own user and project.

## Sample Projects

Sample projects for iOS, tvOS and macOS is included. They all show how to MLGitHubAsset to actually download the asset in the background and utinlize it.

The macOS example project even shows how to show progress and bounce the "Downloads stack" during and after download:

![Dock](Images/Dock.png)

## License

GitHub.Release is released under the [MIT License](https://github.com/MarLoe/GitHub.Release/blob/master/LICENSE).


## Acknowledgements

GitHub is a registered trademark of [GitHub Inc.](https://github.com)
