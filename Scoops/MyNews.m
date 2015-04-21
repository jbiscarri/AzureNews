//
//  MyNews.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//
#import "Scoop.h"
#import "MyNews.h"
#import "NewsCell.h"

#define CELLIDENT @"MyNewCell"


@interface MyNews () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    NSArray *model;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MyNews

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self populateModel];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil]
          forCellWithReuseIdentifier:CELLIDENT];

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

    return cell;
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 30, 10, 30);
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}

#pragma mark - modelo

- (void) populateModel{
    
    Scoop *new1 = [[Scoop alloc]initWithTitle:@"Winter is coming"
                                     andPhoto:nil
                                        aText:@"Winter is comming is the first chapter...."
                                     anAuthor:@"Juan"
                                        aCoor:CLLocationCoordinate2DMake(0, 0)];
    
    Scoop *new2 = [[Scoop alloc]initWithTitle:@"Arcade Fire live"
                                     andPhoto:nil
                                        aText:@"Arcade Fire es uno de los grupos más sorprendetes en directo"
                                     anAuthor:@"Juan"
                                        aCoor:CLLocationCoordinate2DMake(0, 0)];

    
    model = @[new1, new2];
}



@end
