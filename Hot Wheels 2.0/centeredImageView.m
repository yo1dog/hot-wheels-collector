//
//  centeredImageView.m
//  HotWheels 2.0
//
//  Created by Mike on 2/10/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "centeredImageView.h"

@interface centeredImageView ()
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation centeredImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.clipsToBounds = YES;
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
    }
	
    return self;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
