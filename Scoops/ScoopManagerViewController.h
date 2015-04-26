//
//  ScoopManagerViewController.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 18/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);

@interface ScoopManagerViewController : UIViewController<NSURLConnectionDelegate>
{
    NSMutableData* _receivedData;

}


@end
