//
//  Scoop.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Scoop : NSObject


- (void)updateStatus:(NSString*)status;
- (id)initWithTitle:(NSString *)title andPhoto:(NSData *)img aText:(NSString *)text anAuthor:(NSString *)author aCoor:(CLLocationCoordinate2D)coors status:(NSString*)status scoopId:(NSString*)scoopId votes:(int)votes;


@property (readonly) NSString *title;
@property (readonly) NSString *text;
@property (readonly) NSString *author;
@property (readonly) CLLocationCoordinate2D coors;
@property (readonly) NSData *image;
@property (readonly) NSDate *dateCreated;
@property (readonly) NSString *status;
@property (readonly) NSString *scoopId;

@property (readonly) int votes;





@end
