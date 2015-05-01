//
//  PublicNewTableViewCell.h
//  Scoops
//
//  Created by Joan on 01/05/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@protocol PublicNewDelegate <NSObject>

- (void)publicNewDelegateVoted;

@end

@interface PublicNewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *votes;
@property (weak, nonatomic) id<PublicNewDelegate> delegate;

@property (strong, nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (strong, nonatomic) MSClient * client;


- (IBAction)vote:(id)sender;
- (void)configure;


@end
