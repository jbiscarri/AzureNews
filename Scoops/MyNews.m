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

@end

@implementation MyNews

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    model = [@[]mutableCopy];
    [self populateModelFromAzure];
    
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
- (void)populateModelFromAzure{
    
    MSClient *  client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                             applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    MSTable *table = [client tableWithName:@"news"];
    
    MSQuery *queryModel = [[MSQuery alloc]initWithTable:table];
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
    
        
        for (id item in items) {
            NSLog(@"item -> %@", item);
            Scoop *scoop = [[Scoop alloc]initWithTitle:item[@"titulo"] andPhoto:nil aText:item[@"noticia"] anAuthor:@"nil" aCoor:CLLocationCoordinate2DMake(0, 0)];
            [model addObject:scoop];
        }
        [self.collectionView reloadData];
    }];
    
    
}


//- (void) populateModel{
//    
//    UIImage * img2 = [UIImage imageNamed:@"winter-is-coming.jpg"];
//    UIImage * img = [UIImage imageNamed:@"Arcadefire.jpg"];
//    Scoop *new1 = [[Scoop alloc]initWithTitle:@"Winter is coming"
//                                     andPhoto:UIImageJPEGRepresentation(img2, 1.f)
//                                        aText:@"Winter is comming is the first chapter...."
//                                     anAuthor:@"Juan"
//                                        aCoor:CLLocationCoordinate2DMake(0, 0)];
//    
//    Scoop *new2 = [[Scoop alloc]initWithTitle:@"Arcade Fire live"
//                                     andPhoto:UIImageJPEGRepresentation(img, 1.f)
//                                        aText:@"Arcade Fire es uno de los grupos más sorprendetes en directo"
//                                     anAuthor:@"Juan"
//                                        aCoor:CLLocationCoordinate2DMake(0, 0)];
//
//    
//    model = @[new1, new2];
//}



@end
