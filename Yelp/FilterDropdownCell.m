//
//  FilterDropdownCell.m
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterDropdownCell.h"

@interface FilterDropdownCell()

@end
@implementation FilterDropdownCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData: (NSString *)data {
    self.nameLabel.text = data;
}
@end
