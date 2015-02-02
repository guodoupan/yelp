//
//  FilterCell.h
//  Yelp
//
//  Created by Doupan Guo on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterCell;

@protocol FilterCellDelegate <NSObject>

- (void)filterCell:(FilterCell *)cell didChangeValue:(BOOL)value;

@end

@interface FilterCell : UITableViewCell

@property (nonatomic, assign)BOOL on;
@property (nonatomic, weak)id<FilterCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
