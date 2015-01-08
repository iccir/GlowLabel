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


#import "GlowLabel.h"
#import "Effects.h"


static CGFloat sGetScaleFactor()
{
    return [[UIScreen mainScreen] scale];
}

CG_INLINE CGFLOAT_TYPE sScaleRound(CGFLOAT_TYPE x, CGFLOAT_TYPE scaleFactor)
{
    if (!scaleFactor) scaleFactor = sGetScaleFactor();
    return round(x * scaleFactor) / scaleFactor;
}

NS_INLINE BOOL sIsEqual(id a, id b) { return (a == b) || [a isEqual:b]; }


@interface GlowLabelContentView : UIView
@property (nonatomic, weak) GlowLabel *parent;
@property (nonatomic) UIFont *font;
@end


@interface GlowLabel ()
@property (nonatomic) NSStringDrawingContext *stringDrawingContext;
@property (nonatomic) CGFloat expansion;
@end


@implementation GlowLabel {
    GlowLabelContentView *_contentView;
    UIFont *_realFont;
}


- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _realFont = [UIFont systemFontOfSize:17];
        
        _contentView = [[GlowLabelContentView alloc] initWithFrame:CGRectZero];
        [_contentView setOpaque:NO];
        [_contentView setContentMode:UIViewContentModeRedraw];
        [_contentView setParent:self];
        [self addSubview:_contentView];
        
        _stringDrawingContext = [[NSStringDrawingContext alloc] init];
        [_stringDrawingContext setMinimumScaleFactor:0.5];
    }

    return self;
}


#pragma mark - Accessors

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = [self bounds];

    CGRect boundingRect = [_text boundingRectWithSize:bounds.size options:0 attributes:@{
        NSFontAttributeName: _realFont
    } context:_stringDrawingContext];
    
    CGRect contentFrame = CGRectMake(
        0,
        0,
        ceil(_padding.width  + boundingRect.size.width  + _padding.width),
        ceil(_padding.height + boundingRect.size.height + _padding.height)
    );
    
    contentFrame.origin.x = sScaleRound((bounds.size.width  - contentFrame.size.width)  / 2, 0);
    contentFrame.origin.y = sScaleRound((bounds.size.height - contentFrame.size.height) / 2, 0);

    [_contentView setFrame:contentFrame];
    [_contentView setFont:_realFont];
}


- (CGSize) sizeThatFits:(CGSize)size
{
    if (!_text) return CGSizeZero;
    
    CGRect boundingRect = [_text boundingRectWithSize:size options:0 attributes:@{
        NSFontAttributeName: _realFont
    } context:_stringDrawingContext];
    
    boundingRect.size.width  = ceil(boundingRect.size.width);
    boundingRect.size.height = ceil(boundingRect.size.height);
    
    return boundingRect.size;
}


#pragma mark - Accessors

- (void) setText:(NSString *)text
{
    if (!sIsEqual(_text, text)) {
        _text = [text copy];
        [self setNeedsLayout];
        [_contentView setNeedsDisplay];
    }
}


- (void) setFont:(UIFont *)font
{
    if (!sIsEqual(_font, font)) {
        _font = font;
        _realFont = font ? font : [UIFont systemFontOfSize:17];
        [self setNeedsLayout];
        [_contentView setNeedsDisplay];
    }
}


- (void) setTextColor:(UIColor *)textColor
{
    if (!sIsEqual(_textColor, textColor)) {
        _textColor = textColor;
        [_contentView setNeedsDisplay];
    }
}


- (void) setFirstBlurRadius:(CGFloat)firstBlurRadius
{
    if (_firstBlurRadius != firstBlurRadius) {
        _firstBlurRadius = firstBlurRadius;
        [self setNeedsLayout];
        [_contentView setNeedsDisplay];
    }
}


- (void) setThreshold:(float)threshold
{
    if (_threshold != threshold) {
        _threshold = threshold;
        [self setNeedsLayout];
        [_contentView setNeedsDisplay];
    }
}


- (void) setSecondBlurRadius:(CGFloat)secondBlurRadius
{
    if (_secondBlurRadius != secondBlurRadius) {
        _secondBlurRadius = secondBlurRadius;
        [self setNeedsLayout];
        [_contentView setNeedsDisplay];
    }
}


- (void) setUsesHighQualityGlow:(BOOL)usesHighQualityGlow
{
    if (_usesHighQualityGlow != usesHighQualityGlow) {
        _usesHighQualityGlow = usesHighQualityGlow;
        [_contentView setNeedsDisplay];
    }
}



@end


@implementation GlowLabelContentView

- (void) drawRect:(CGRect)rect
{
    CGRect  bounds = [self bounds];
    CGFloat scale  = [self contentScaleFactor];
    
    if (!scale) return;

    GlowLabel *parent  = [self parent];
    CGSize     padding = [parent padding];

    UIColor *color = [parent textColor];
    if (!color) color = [UIColor blackColor];

    CGRect textRect = bounds;
    textRect = CGRectInset(textRect, padding.width, padding.height);
    
    DrawGlowText(
        bounds,
        scale,
        UIGraphicsGetCurrentContext(),
        textRect,
        [parent text],
        [self font],
        color,
        [parent glowColor],
        [parent firstBlurRadius],
        [parent secondBlurRadius],
        [parent threshold],
        [parent usesHighQualityGlow]
    );
}


@end