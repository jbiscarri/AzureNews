//
//  ReaderViewController.m
//  Scoops
//
//  Created by Joan on 01/05/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "ReaderViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "ScoopManagerViewController.h"
#import "sharedkeys.h"
#import "MBProgressHUD.h"

@interface ReaderViewController (){
    MSClient * client;
}
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation ReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getNews];
}

- (void)getNews
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = @"Loading News";
    [hud show:YES];

    
    if (client == nil)
        [self warmupMSClient];
    [client invokeAPI:@"getpublishednews" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        
        if (error == nil)
        {
            self.datasource = result;
        }else{
            self.datasource = @[];
        }
        [self.tableView reloadData];
        [hud hide:YES];

    }];

}

-(void)warmupMSClient{
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", client.debugDescription);
}

#pragma mark - TableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PublicNewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublishedNewsCell" forIndexPath:indexPath];
    cell.data = self.datasource[indexPath.row];
    cell.client = client;
    cell.delegate = self;
    [cell configure];
    return cell;
}
#pragma mark - PublicNewDelegate
- (void)publicNewDelegateVoted
{
    [self getNews];
}

@end
