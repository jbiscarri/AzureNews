//
//  NewsCell.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@protocol NewsCellDelegate <NSObject>

- (void)NewsCellDelegateShouldUpdateCollection;

@end


@class Scoop;

@interface NewsCell : UICollectionViewCell

@property (weak, nonatomic) id<NewsCellDelegate> delegate;
@property (strong, nonatomic) Scoop *scoop;
@property (nonatomic) BOOL statusNew;
@property (nonatomic, strong) MSClient *client;
@property (weak, nonatomic) IBOutlet UILabel *votes;


@end
