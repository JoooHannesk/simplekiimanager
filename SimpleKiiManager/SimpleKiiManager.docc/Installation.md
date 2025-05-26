# Installation
How to add this framework to your Xcode project.

1. Checkout the latest version:
```bash
git clone https://bitbucket.org/swift-projects/simplekiimanager.git
```
2. Add the framwork to your existing Xcode project.
    1. Add SimpleKiiManager sources to your project
![Add SimpleKiiManager Sources to your Project](add-repo)
    2. Select local repo (which was cloned in step 1)
![Select cloned repo](select-repo)
    3. Add framework to your current project/workspace
![Add framework to Workspace](framework-added-to-workspace)
    4. Add framework to target (in case `Workspace` is not listed, close your project, restart Xcode and try again)
![Add framework to target](add-framework-to-target)
    5. Framework was added to target
![Framework was added to target](framework-added-to-target)

## Signing and Capabilities
For storing login information in the iOS/macOS keychain, no special entitlements or capabilities are required beyond the default app setup.
