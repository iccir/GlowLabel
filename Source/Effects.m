/*
    Copyright (c) 2015, Ricci Adams

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following condition is met:

    1. Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer. 

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "Effects.h"

@import Accelerate;


static void sThreshold(UInt8 *inBytes, size_t size, UInt8 threshold)
{
    for (NSInteger i = 0; i < size; i++) {
        UInt8 value = inBytes[i];
        
        if (value > threshold) {
            inBytes[i] = 255;
        } else {
            inBytes[i] = 0;
        }
    }
}


extern void DrawGlowText(
    CGRect       bounds,
    CGFloat      scale,
    CGContextRef context,
    CGRect       textRect,
    NSString    *text,
    UIFont      *font,
    UIColor     *textColor,
    UIColor     *glowColor,
    CGFloat      blur1,
    CGFloat      blur2,
    float        threshold,
    BOOL         highQualityGlow
) {
    void (^makeContext)(CGContextRef *, vImage_Buffer *, BOOL) = ^(CGContextRef *outContext, vImage_Buffer *outBuffer, BOOL useScale) {
        size_t width  = bounds.size.width  * (useScale ? scale : 1);
        size_t height = bounds.size.height * (useScale ? scale : 1);
        
        CGBitmapInfo bitmapInfo = 0 | kCGImageAlphaOnly;
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width, NULL, bitmapInfo);

        outBuffer->data     = CGBitmapContextGetData(context);
        outBuffer->width    = CGBitmapContextGetWidth(context);
        outBuffer->height   = CGBitmapContextGetHeight(context);
        outBuffer->rowBytes = CGBitmapContextGetBytesPerRow(context);
        
        *outContext = context;
    };

    CGContextRef c1; vImage_Buffer v1;
    makeContext(&c1, &v1, YES);

    CGContextScaleCTM(c1, scale, scale);
    UIGraphicsPushContext(c1);
    [text drawInRect:textRect withAttributes:@{ NSFontAttributeName: font }];
    UIGraphicsPopContext();
    
    if (threshold < 0) threshold = 0;
    if (threshold > 1) threshold = 1;
    UInt8 t = round(threshold * 255);

    if (glowColor) {
        CGContextRef c2; vImage_Buffer v2;
        makeContext(&c2, &v2, highQualityGlow);

        CGContextRef c3; vImage_Buffer v3;
        makeContext(&c3, &v3, highQualityGlow);

        if (highQualityGlow) {
            blur1 *= scale;
            blur2 *= scale;
        }

        {
            UInt32 k1 = floor(blur1 * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (k1 % 2 != 1) k1++;

            UInt32 k2 = floor(blur2 * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (k2 % 2 != 1) k2++;

            ssize_t tmpBufferSize1 = vImageBoxConvolve_Planar8(&v2, &v3, NULL, 0, 0, k1, k1, 0,  kvImageEdgeExtend|kvImageGetTempBufferSize);
            ssize_t tmpBufferSize2 = vImageBoxConvolve_Planar8(&v2, &v3, NULL, 0, 0, k2, k2, 0,  kvImageEdgeExtend|kvImageGetTempBufferSize);

            void *tmpBuffer = malloc(MAX(tmpBufferSize1, tmpBufferSize2));

            if (highQualityGlow) {
                vImageBoxConvolve_Planar8(&v1, &v2, tmpBuffer, 0, 0, k1, k1, 0, kvImageEdgeExtend);
            } else {
                vImageScale_Planar8(&v1, &v3, NULL, kvImageEdgeExtend);
                vImageBoxConvolve_Planar8(&v3, &v2, tmpBuffer, 0, 0, k1, k1, 0, kvImageEdgeExtend);
            }

            vImageBoxConvolve_Planar8(&v2, &v3, tmpBuffer, 0, 0, k1, k1, 0, kvImageEdgeExtend);
            vImageBoxConvolve_Planar8(&v3, &v2, tmpBuffer, 0, 0, k1, k1, 0, kvImageEdgeExtend);

            sThreshold(v2.data, v2.width * v2.height, t);
            
            vImageBoxConvolve_Planar8(&v2, &v3, tmpBuffer, 0, 0, k2, k2, 0, kvImageEdgeExtend);
            vImageBoxConvolve_Planar8(&v3, &v2, tmpBuffer, 0, 0, k2, k2, 0, kvImageEdgeExtend);
            vImageBoxConvolve_Planar8(&v2, &v3, tmpBuffer, 0, 0, k2, k2, 0, kvImageEdgeExtend);

            free(tmpBuffer);
        }

        CGImageRef glowImage = CGBitmapContextCreateImage(c3);
        [glowColor set];
        
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextDrawImage(context, bounds, glowImage);
    
        CGImageRelease(glowImage);

        CGContextRelease(c2);
        CGContextRelease(c3);
    }

    // Draw text
    {
        CGImageRef textImage = CGBitmapContextCreateImage(c1);
        
        [textColor set];
        CGContextDrawImage(context, bounds, textImage);
        
        CGImageRelease(textImage);
    }
    
    CGContextRelease(c1);
}
