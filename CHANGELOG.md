## 4.0.0

- Initial version, created by Stagehand

## 5.0.4

- Fixed Authorization Bugs

## 5.1.0

- BREAKING CHANGE: Authorization API Change.

## 5.1.1

- Formatting changes.

## 5.2.3

- BREAKING CHANGE: Request API Change.

## 5.2.4

- Remove unused package

## 5.2.5

- BREAKING CHANGE: Remove Author Meta & Featured Image Url Fields from Post response. (these were not in the base api response, you can add them using custom plugins.)

## 5.2.6

- Experimental Request Caching system

## 5.2.7

- Bug fix

## 5.2.8

- Revert author meta & featured image removal

## 5.2.9

- Bug Fix

## 5.3.0

- Bug fix

## 5.3.1

- Response structure fix

## 5.4.0

- Packages update

## 5.4.1

- Null safety fix

## 5.4.2

- Packages fix

## 5.4.3

- Total pages parsing fix

## 6.1.0-pre

- Entire API changed. (Sorry for this, but this had to be done sooner or later!)
- Fluency is maintaned by using Dart's cascading operator.
- Performence as been improved, as well as memory consumption.

## 6.1.1-pre

- Removed test package

## 6.1.2-pre

- Version fix

## 6.1.3-pre

- Bug fixes

## 6.1.4-pre

- Bug fixes

# 6.1.5-pre

- Added Post extension for getting Media and Author

# 6.1.6-pre

- Support 3xx series respones (Cached Response)

# 6.1.7-pre

- Refactoring

# 6.1.8-pre

- Bug fixes

# 6.1.9-pre

- Bug fixes


# 6.2.0-pre

- Refactoring
- Request Synchronization
- Debug Mode

# 6.2.1-pre

- Misc

# 6.3.0

- Lots of changes in the API
- Please check the wiki for setting up and usage to know about the changed API

# 6.3.1

- Implemented search endpoint

# 6.3.4

- Bug fix with media endpoint

# 7.0.0

- [BREAKING] Upgraded minimum dart version to >= 2.18.0.
- [BREAKING] Upgraded outdated dependencies.
- Added new "self" property for all response models. It will contain the entire JSON response as a Map. Thanks @mikhaelpurba (Previous syntax "json" has been deprecated)
- All response classes now override equality and hashCode properties, along with toString() method.
- Usual amount of code refactors and fixes.