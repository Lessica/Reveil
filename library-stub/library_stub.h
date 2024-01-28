//
//  library_stub.h
//  library-stub
//
//  Created by Lessica on 2023/11/2.
//

#import <Foundation/Foundation.h>

//! Project version number for library_stub.
FOUNDATION_EXPORT double library_stubVersionNumber;

//! Project version string for library_stub.
FOUNDATION_EXPORT const unsigned char library_stubVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <library_stub/PublicHeader.h>
FOUNDATION_EXPORT int evaluateSignature(NSURL *fileURL, NSData **cdHashOut, BOOL *isAdhocSignedOut);
FOUNDATION_EXPORT BOOL isCdHashInTrustCache(NSData *cdHash);
