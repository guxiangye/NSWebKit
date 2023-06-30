//
//  NSPickLocationSearchPOICell.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "Masonry.h"
#import "NSPickLocationSearchPOICell.h"
#import "UIColor+YYAdd.h"
#import "UIImage+YYAdd.h"
#import "MAGeometry.h"

@interface NSPickLocationSearchPOICell () {
    UILabel *nameLabel;
    UILabel *subLabel;
    UIImageView *selectedImageView;
}
@end

@implementation NSPickLocationSearchPOICell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        selectedImageView = [UIImageView new];
        selectedImageView.image = [[UIImage imageNamed:@"img_pick_location_check"]imageByTintColor:[UIColor colorWithHexString:@"#57bf6a"]];
        [self.contentView addSubview:selectedImageView];
        [selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-20);
            make.width.equalTo(@24);
        }];
        selectedImageView.hidden = YES;

        nameLabel = [UILabel new];
        subLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.top.equalTo(@20);
            make.right.equalTo(selectedImageView.mas_left).offset(0);
        }];

        subLabel = [UILabel new];
        [self.contentView addSubview:subLabel];
        subLabel.textColor = [UIColor colorWithHexString:@"#9094A2"];
        subLabel.font = [UIFont systemFontOfSize:13];
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(5);
            make.right.equalTo(selectedImageView.mas_left).offset(0);
        }];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)setPoi:(AMapPOI *)poi {
    _poi = poi;

    if (_poi) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_poi.name];

        if(self.keywords.length > 0){
            NSArray *keywordsArr = [self.keywords componentsSeparatedByString:@""];
            NSArray *nameArr = _poi.name ? [_poi.name componentsSeparatedByString:@""] : @[];
            for(int i = 0;i < nameArr.count;i++){
                NSString *charStr = nameArr[i];
                if([keywordsArr containsObject:charStr]){
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#57bf6a"] range:NSMakeRange(i, 1)];
                    
                }
            }
        }
        
        nameLabel.attributedText = attributedString;
        NSString *distanceStr = @"";
        
        
        MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.currentPOISearchCoordinate.latitude,self.currentPOISearchCoordinate.longitude));
        MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude));
        //2.计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        

        if (distance <= 100) {
            distanceStr = @"100m内";
        } else if (distance <= 1000){
            distanceStr = [NSString stringWithFormat:@"%dm", (int)distance];
        }
        else{
            distanceStr = [NSString stringWithFormat:@"%.2fkm", distance/1000];
        }

        subLabel.text = [NSString stringWithFormat:@"%@|%@%@", distanceStr, _poi.district, _poi.address];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    selectedImageView.hidden = !selected;

    // Configure the view for the selected state
}

@end
