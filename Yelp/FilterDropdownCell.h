//
//  FilterDropdownCell.h
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterDropdownCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconLabel;

- (void)setData: (NSString *)data;
@end
