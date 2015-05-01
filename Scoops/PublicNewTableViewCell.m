//
//  PublicNewTableViewCell.m
//  Scoops
//
//  Created by Joan on 01/05/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "PublicNewTableViewCell.h"
#import "MBProgressHUD.h"

@implementation PublicNewTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)vote:(id)sender {
    NSDictionary *dict = @{@"newsId":self.data[@"id"]};
    
    [self.client invokeAPI:@"votefornew" body:nil HTTPMethod:@"POST" parameters:dict headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        
        if (error == nil)
        {
            [self.delegate publicNewDelegateVoted];
        }else{
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = @"Error voting";
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        }
        
    }];
}

- (void)configure
{
    self.title.text = self.data[@"titulo"];
    self.author.text = self.data[@"autor"];
    self.votes.text = [NSString stringWithFormat:@"Votes: %d", [self.data[@"votes"] intValue]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.data[@"imageuri"]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cellImage.image = image;
        });
    });

    
}
@end
