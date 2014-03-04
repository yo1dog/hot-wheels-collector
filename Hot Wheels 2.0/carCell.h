//
//  CarSearchResultCell.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Car.h"
#import "CarCellBadgeButton.h"

@interface CarCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel                 *label;
@property (nonatomic, weak) IBOutlet UIImageView             *imageView;
@property (nonatomic, weak) IBOutlet UIImageView             *badgeImageView;
@property (nonatomic, weak) IBOutlet CarCellBadgeButton      *badgeButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@end
