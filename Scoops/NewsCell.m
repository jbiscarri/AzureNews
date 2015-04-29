//
//  NewsCell.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "NewsCell.h"

#import "Scoop.h"


@interface NewsCell()
@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UILabel *titleNews;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;

@end

@implementation NewsCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}


- (void)prepareForReuse{
    
    self.imagen.image = nil;
    self.titleNews.text = @" ";
    self.status.text = @" ";
}

- (void)setScoop:(Scoop *)scoop{
    
    _scoop = scoop;
    
    self.imagen.image = [UIImage imageWithData:_scoop.image];
    self.titleNews.text = _scoop.title;
    self.status.text = _scoop.status;
    self.publishButton.hidden = [_scoop.status isEqualToString:@"PUBLISHED"];
    
}
- (IBAction)publishClicked:(id)sender {
    if (self.client.currentUser){
        [self.client invokeAPI:@"preparetopublishnew" body:nil HTTPMethod:@"POST" parameters:@{@"newsId":self.scoop.scoopId} headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            if (error == nil)
            {
                [self.scoop updateStatus:@"PENDING"];
                [self.delegate NewsCellDelegateShouldUpdateCollection];
            }
        }];
    }
    
}

@end
