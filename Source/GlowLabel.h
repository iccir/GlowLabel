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


@import UIKit;

@interface GlowLabel : UIView

@property (nonatomic, copy) NSString *text;      // default is nil

@property (nonatomic) UIFont   *font;            // default is nil (system font 17 plain)
@property (nonatomic) UIColor  *textColor;       // default is nil (text draws black)
@property (nonatomic) UIColor  *glowColor;       // default is nil (no glow)

// Expands size of content view to allow room for glow
@property (nonatomic) CGSize padding;

@property (nonatomic) CGFloat firstBlurRadius;
@property (nonatomic) float   threshold;        // 0.0 to 1.0
@property (nonatomic) CGFloat secondBlurRadius;
@property (nonatomic) BOOL    usesHighQualityGlow;

@end
