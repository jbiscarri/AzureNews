//
//  ReaderViewController.h
//  Scoops
//
//  Created by Joan on 01/05/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicNewTableViewCell.h"


@interface ReaderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PublicNewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
