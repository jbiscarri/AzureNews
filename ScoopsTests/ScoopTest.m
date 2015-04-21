//
//  ScoopTest.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Scoop.h"

@interface ScoopTest : XCTestCase

@end

@implementation ScoopTest



- (void)testNewScoop{
     Scoop *scoop = [[Scoop alloc]initWithTitle:@"Titulo" andPhoto:nil aText:@"lorem ipsum" anAuthor:@"Juan" aCoor:CLLocationCoordinate2DMake(0.51, 0.51)];
    
    XCTAssertNotNil(scoop.title, @"La noticia tiene titulo");
    XCTAssertNotNil(scoop.text, @"La noticia tiene un texto");
    
    if ([scoop.dateCreated isKindOfClass:[NSDate class]]) {
        XCTAssertNotNil(scoop.dateCreated, @"La noticia tiene fecha");
        
    } else {
        XCTAssertThrows(@"No tiene fecha");
    }
    
    
}


- (void)testScoopEquality{
    Scoop *scoop = [[Scoop alloc]initWithTitle:@"Titulo" andPhoto:nil aText:@"lorem ipsum" anAuthor:@"Juan" aCoor:CLLocationCoordinate2DMake(0.51, 0.51)];
    Scoop *news = [[Scoop alloc]initWithTitle:@"Titulo" andPhoto:nil aText:@"lorem ipsum" anAuthor:@"Juan" aCoor:CLLocationCoordinate2DMake(0.51, 0.51)];
  
    
    XCTAssertEqualObjects(scoop, news, @"Es la misma noticia");
}

- (void)testHash{
    Scoop *scoop = [[Scoop alloc]initWithTitle:@"Titulo" andPhoto:nil aText:@"lorem ipsum" anAuthor:@"Juan" aCoor:CLLocationCoordinate2DMake(0.51, 0.51)];
    Scoop *news = [[Scoop alloc]initWithTitle:@"La leyenda del" andPhoto:nil aText:@"lorem ipsum" anAuthor:@"Juan" aCoor:CLLocationCoordinate2DMake(0.51, 0.51)];
  
    XCTAssertNotEqual([scoop hash], [news hash], @"Estos cobejtos tienen el mismo hash");
    
}


@end
