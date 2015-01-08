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


#import "ViewController.h"
#import "GlowLabel.h"


@implementation ViewController {
    GlowLabel *_label;
    dispatch_source_t _tickTimer;
    NSDateFormatter *_dateFormatter;
}


- (void) viewDidLoad
{
    [super viewDidLoad];

    _label = [[GlowLabel alloc] initWithFrame:[[self container] bounds]];
    [[self container] addSubview:_label];

    [_label setTextColor:[UIColor redColor]];
    [_label setGlowColor:[UIColor blueColor]];

    [self _updateValues];

    _tickTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    __weak id weakSelf = self;
    
    dispatch_source_set_timer(_tickTimer, dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), 0.1 * NSEC_PER_SEC, (0.1 * NSEC_PER_SEC) / 10);
    dispatch_source_set_event_handler(_tickTimer, ^{
        [weakSelf _tick];
    });

    dispatch_resume(_tickTimer);
    
    [self _tick];
}


- (void) _tick
{
    NSString *text = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle];
    [_label setText:text];
}


- (void) _updateValues
{
    float blur1     = [[self blur1Slider] value];
    float blur2     = [[self blur2Slider] value];
    float size      = [[self sizeSlider]  value];
    float threshold = [[self thresholdSlider] value];
    float padWidth  = [[self padWidthSlider] value];
    float padHeight = [[self padHeightSlider] value];

    BOOL useHQ = [[self qualitySegmentedControl] selectedSegmentIndex] > 0;

    padWidth  = round(padWidth);
    padHeight = round(padHeight);
    
    [[self padWidthSlider]  setValue:padWidth];
    [[self padHeightSlider] setValue:padHeight];
    
    [_label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:size]];
    [_label setThreshold:threshold];
    [_label setFirstBlurRadius:blur1];
    [_label setSecondBlurRadius:blur2];
    [_label setPadding:CGSizeMake(padWidth, padHeight)];
    [_label setUsesHighQualityGlow:useHQ];

    CGSize labelSize = [_label sizeThatFits:CGSizeMake(9999, 9999)];

    CGRect outer = [_container bounds];
    CGRect inner = CGRectMake(0, 0, labelSize.width, labelSize.height);
    
    inner.origin.x = round((outer.size.width  - inner.size.width)  / 2);
    inner.origin.y = round((outer.size.height - inner.size.height) / 2);

    [_label setFrame:inner];
}


- (IBAction) sliderChanged:(id)sender
{
    [self _updateValues];
}


@end
