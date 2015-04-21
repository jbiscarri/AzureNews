//
//  ScoopManagerViewController.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 18/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "ScoopManagerViewController.h"
#import "Constants.h"
#import "ContainerViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Scoop.h"

@interface ScoopManagerViewController ()
{
    MSClient *client;
}

@property (weak, nonatomic) ContainerViewController * containerViewController;
@property (nonatomic) CGRect oldRect;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *boxNews;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarView;

@end

@implementation ScoopManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupKeyboardNotifications];
    [self warmUpMSClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"EmbedContainer"] ) {
        self.containerViewController = segue.destinationViewController;
    }
}

- (IBAction)swapAction:(id)sender {
    [self.containerViewController swapViewControllers];
}
- (IBAction)ownNews:(id)sender {
    [self.containerViewController swapViewControllers];

}

#pragma mark - Azure connect, setup, login etc...

- (void)warmUpMSClient
{
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:kAzureEndPoint]
                                 applicationKey:kAzureAppKey];
    NSLog(@"%@", client.debugDescription);

}

- (void)addNewToAzure
{

    MSTable *news = [client tableWithName:@"news"];
    /*
    Scoop *scoop = [[Scoop alloc] initWithTitle:self.titleText.text
                                       andPhoto:nil
                                          aText:self.boxNews.text
                                       anAuthor:nil
                                          aCoor:CLLocationCoordinate2DMake(0, 0)];
     */
    NSDictionary *scoop = @{@"titulo": self.titleText.text,
                            @"noticia": self.boxNews.text};
    [news insert:scoop
      completion:^(NSDictionary *item, NSError *error) {
          if (error){
              NSLog(@"Error %@", error);
          }else{
              NSLog(@"Ok");
          }
      }];
}

#pragma mark - keyboard

- (void)setupKeyboardNotifications{
    
    // Alta en notificaciones
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillAppear:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillDisappear:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
}

//UIKeyboardWillShowNotification
-(void)notifyKeyboardWillAppear: (NSNotification *) notification{
    
    // Obtener el frame del teclado
    NSDictionary *info = notification.userInfo;
    NSValue *keyFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyFrame = [keyFrameValue CGRectValue];
    
    
    // La duración de la animación del teclado
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Nuevo CGRect
    self.oldRect = self.boxNews.frame;
    CGRect newRect = CGRectMake(self.oldRect.origin.x,
                                self.oldRect.origin.y,
                                self.oldRect.size.width,
                                self.oldRect.size.height - keyFrame.size.height + self.toolBarView.frame.size.height - 10);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         self.boxNews.frame = newRect;
                     } completion:^(BOOL finished) {
                         //
                     }];
    
}

// UIKeyboardWillHideNotification
-(void)notifyKeyboardWillDisappear: (NSNotification *) notification{
    
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         self.boxNews.frame = self.oldRect;
                     } completion:^(BOOL finished) {
                         //
                     }];
}

- (IBAction)addNew:(id)sender {
    [self addNewToAzure];
    
}
- (IBAction)takePhoto:(id)sender {
    
}

@end
