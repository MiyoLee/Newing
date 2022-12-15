#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UntaggerHTMLParser.h"
#import "UntaggerHTMLParserDelegate.h"
#import "Untagger.h"

FOUNDATION_EXPORT double UntaggerVersionNumber;
FOUNDATION_EXPORT const unsigned char UntaggerVersionString[];

