//
//  BusinessAnnotation.h
//  Yelp
//
//  Created by Doupan Guo on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface BusinessAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (void)setTitle:(NSString *)pTitle;

@property (nonatomic, strong) NSURL *rating_img_url;
@property (nonatomic) NSInteger reviewCount;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic) BOOL isClosed;
@end
