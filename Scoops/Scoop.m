//
//  Scoop.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "Scoop.h"


@interface Scoop ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *author;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *scoopId;
@property (nonatomic, assign) int votes;






@end


@implementation Scoop


-(id)initWithTitle:(NSString *)title andPhoto:(NSData *)img aText:(NSString *)text anAuthor:(NSString *)author aCoor:(CLLocationCoordinate2D)coors status:(NSString*)status scoopId:(NSString*)scoopId votes:(int)votes  {
    
    if (self = [super init]) {
        _title = title;
        _text = text;
        _author = author;
        _coors = coors;
        _image = img;
        _dateCreated = [NSDate date];
        _status = status;
        _scoopId = scoopId;
        _votes = votes;
    }
    
    return self;
    
}

- (void)updateStatus:(NSString*)status
{
    self.status = status;
}


#pragma mark - Overwritten

-(NSString*) description{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], self.title];
}


- (BOOL)isEqual:(id)object{
    
    
    return [self.title isEqualToString:[object title]];
}

- (NSUInteger)hash{
    return [_title hash] ^ [_text hash];
}








@end
