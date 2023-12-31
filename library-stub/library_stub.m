//
//  library_stub.m
//  library-stub
//
//  Created by Lessica on 2023/11/2.
//

#import "library_stub.h"
#import <IOKit/IOKitLib.h>
#import <mach/mach_error.h>
#import "macho.h"

#define AMFI_IS_CD_HASH_IN_TRUST_CACHE 6

int evaluateSignature(NSURL* fileURL, NSData **cdHashOut, BOOL *isAdhocSignedOut)
{
    if (!fileURL || (!cdHashOut && !isAdhocSignedOut)) return 1;
    if (![fileURL checkResourceIsReachableAndReturnError:nil]) return 2;

    FILE *machoFile = fopen(fileURL.fileSystemRepresentation, "rb");
    if (!machoFile) return 3;

    BOOL isMacho = NO;
    machoGetInfo(machoFile, &isMacho, NULL);

    if (!isMacho) {
        fclose(machoFile);
        return 4;
    }

    int64_t archOffset = machoFindBestArch(machoFile);
    if (archOffset < 0) {
        fclose(machoFile);
        return 5;
    }

    uint32_t CSDataStart = 0, CSDataSize = 0;
    machoFindCSData(machoFile, (uint32_t)archOffset, &CSDataStart, &CSDataSize);
    if (CSDataStart == 0 || CSDataSize == 0) {
        fclose(machoFile);
        return 6;
    }

    BOOL isAdhocSigned = machoCSDataIsAdHocSigned(machoFile, CSDataStart, CSDataSize);
    if (isAdhocSignedOut) {
        *isAdhocSignedOut = isAdhocSigned;
    }

    // we only care about the cd hash on stuff that's already verified to be ad hoc signed
    if (isAdhocSigned && cdHashOut) {
        *cdHashOut = machoCSDataCalculateCDHash(machoFile, CSDataStart, CSDataSize);
    }

    fclose(machoFile);
    return 0;
}

BOOL isCdHashInTrustCache(NSData *cdHash)
{
    kern_return_t kr;

    CFMutableDictionaryRef amfiServiceDict = IOServiceMatching("AppleMobileFileIntegrity");
    if (amfiServiceDict)
    {
        io_connect_t connect;
        io_service_t amfiService = IOServiceGetMatchingService(kIOMainPortDefault, amfiServiceDict);
        kr = IOServiceOpen(amfiService, mach_task_self(), 0, &connect);
        if (kr != KERN_SUCCESS)
        {
            NSLog(@"Failed to open amfi service %d %s", kr, mach_error_string(kr));
            return NO;
        }

        uint64_t includeLoadedTC = YES;
        kr = IOConnectCallMethod(connect, AMFI_IS_CD_HASH_IN_TRUST_CACHE, &includeLoadedTC, 1, CFDataGetBytePtr((__bridge CFDataRef)cdHash), CFDataGetLength((__bridge CFDataRef)cdHash), 0, 0, 0, 0);
        NSLog(@"Is %s in TrustCache? %s", cdHash.description.UTF8String, kr == 0 ? "Yes" : "No");

        IOServiceClose(connect);
        return kr == KERN_SUCCESS;
    }

    return NO;
}
