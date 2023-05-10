
This repository contains a template to use for starting a Skip project.

You can clone this repository directory to experiment with Skip,
or else use it as a template for a new Skip project of your own. 

## TLDR

Run the following command from the terminal to checkout
the project then transpile, build, and test both the
Swift and Kotlin parts of the project using the system Gradle 
(which can be installed with `brew install gradle`):

```shell
cd `mktemp -d` && git clone https://github.com/skiptools/skip-template.git && cd skip-template && swift test
```

## Testing from the CLI

Check out the reppository, such as by running the following commands from the command line:

```shell
git clone https://github.com/skiptools/skip-template.git
cd skip-template/
```

You can then transpile and build the project and run the
test cases with:

```shell
swift test
```

Or, using xcodebuild:

```shell
xcodebuild test -configuration Debug -sdk "macosx" -destination "platform=macosx" -skipPackagePluginValidation -scheme TemplateLibKt
```

## Renaming the Template

When creating a new repository from this template,
there is no convenient way to rename the module
from "TemplateLib" to a new module name.

The following terminal commands will rename the
modules and associated files to whatever you set the
`MODULE_NAME` variable to.

**WARNING**: there is no way to undo this, so only run the commands
in a freshly checked-out repository.

```shell
MODULE_NAME=MyNewPackageName 

find .swiftpm Package.swift Skip Sources Tests -type f -exec sed -i '' "s/TemplateLib/${MODULE_NAME}/g" {} \;
find . -depth -type d -name '*TemplateLib*' -exec sh -c 'mv -v "$0" "${0/TemplateLib/'${MODULE_NAME}'}"' {} \;
find . -depth -type f -name '*TemplateLib*' -exec sh -c 'mv -v "$0" "${0/TemplateLib/'${MODULE_NAME}'}"' {} \; 
```

