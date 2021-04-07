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

#import "MMRtcKit.h"
#import "MMRtcEngineKit.h"
#import "MMRtcEnumerates.h"
#import "MMRtcVideoCanvas.h"
#import "MMRtcVideoConfiguration.h"

FOUNDATION_EXPORT double MMRtcKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MMRtcKitVersionString[];

