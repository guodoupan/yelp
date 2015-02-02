//
//  FilterCell.m
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterCell.h"

@interface FilterCell()
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;


@end

@implementation FilterCell

- (void)awakeFromNib {
    // Initialization code
    self.filterLabel.preferredMaxLayoutWidth = self.filterLabel.frame.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSString *)data {
    self.filterLabel.text = data;
    //self.filterSwitch. = data[@"value"];
}
@end
