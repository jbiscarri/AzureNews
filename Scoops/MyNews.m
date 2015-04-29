//
//  MyNews.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Scoop.h"
#import "MyNews.h"
#import "NewsCell.h"
#import "sharedkeys.h"


#define CELLIDENT @"MyNewCell"


@interface MyNews () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    NSMutableArray *model;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) MSClient *client;


@end

@implementation MyNews

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    model = [@[]mutableCopy];
    //[self populateModelFromAzure];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil]
          forCellWithReuseIdentifier:CELLIDENT];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedThatUsetHasBeenLoggedIn:) name:@"USER_LOGGED_IN" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedThatShouldRefreshData:) name:@"SHOULD_REFRESH_DATA" object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"News -> %ld", model.count);
    return model.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NewsCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELLIDENT forIndexPath:indexPath];
    cell.scoop = model[indexPath.row];
    cell.client = self.client;
    cell.delegate = self;
    return cell;
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, collectionView.frame.size.height);
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 30, 5, 30);
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}

#pragma mark - modelo
- (void)populateModelFromAzure:(MSClient*)client{
    _client = client;
    MSTable *table = [client tableWithName:@"news"];
    
    MSQuery *queryModel = [[MSQuery alloc] initWithTable:table];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@", client.currentUser.userId];
    queryModel.predicate = predicate;
    model = [@[]mutableCopy];

    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (id item in items) {
                NSData *data;
                if (item[@"imageuri"] != nil && item[@"imageuri"] != [NSNull null]){
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item[@"imageuri"]]];
                }
                NSLog(@"item -> %@", item);
                Scoop *scoop = [[Scoop alloc] initWithTitle:item[@"titulo"]
                                                   andPhoto:data
                                                      aText:item[@"noticia"]
                                                   anAuthor:item[@"autor"]
                                                      aCoor:CLLocationCoordinate2DMake(0, 0)
                                                     status:item[@"estado"]
                                                    scoopId:item[@"id"]
                                                      votes:[item[@"votes"] intValue]];
                [model addObject:scoop];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        //});
    }];
    
    
}

- (void)notifiedThatUsetHasBeenLoggedIn:(NSNotification*)notification
{
    MSClient *client = notification.userInfo[@"client"];
    [self populateModelFromAzure:client];
}

- (void)notifiedThatShouldRefreshData:(NSNotification*)notification
{
    [self populateModelFromAzure:self.client];
}

#pragma mark - NewsCellDelegate

- (void)NewsCellDelegateShouldUpdateCollection{
    [self.collectionView reloadData];
}

@end
