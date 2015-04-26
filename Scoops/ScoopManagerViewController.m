//
//  ScoopManagerViewController.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 18/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//



@import QuartzCore;


#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "ScoopManagerViewController.h"
#import "ContainerViewController.h"
#import "sharedkeys.h"
#import "Scoop.h"

@interface ScoopManagerViewController (){
    
    MSClient * client;
    
    NSString *userFBId;
    NSString *tokenFB;
}

@property (weak, nonatomic) ContainerViewController * containerViewController;
@property (nonatomic) CGRect oldRect;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *boxNews;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarView;
@property (weak, nonatomic) IBOutlet UIImageView *picProfile;
@property (strong, nonatomic) NSURL *profilePicture;

@end

@implementation ScoopManagerViewController


-(void)setProfilePicture:(NSURL *)profilePicture{
    
    _profilePicture = profilePicture;
    
    dispatch_queue_t queue = dispatch_queue_create("com.byjuanamn.serial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        NSData *buff = [NSData dataWithContentsOfURL:profilePicture];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.picProfile.image = [UIImage imageWithData:buff];
            self.picProfile.layer.cornerRadius = self.picProfile.frame.size.width / 2;
            self.picProfile.clipsToBounds = YES;
        });
       
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupKeyboardNotifications];
    
    
    // llamamos a los metodos de Azure para crear y configurar la conexion
    [self warmupMSClient];
    
    [self loginUser];
}

- (void)viewWillAppear:(BOOL)animated{
   
    [super viewDidAppear:animated];
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

-(void)warmupMSClient{
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", client.debugDescription);
}

- (void)addNewToAzure{
    MSTable *news = [client tableWithName:@"news"];
//    Scoop *scoop = [[Scoop alloc]initWithTitle:self.titleText.text
//                                      andPhoto:nil
//                                         aText:self.boxNews.text
//                                      anAuthor:@""
//                                         aCoor:CLLocationCoordinate2DMake(0, 0)];
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    NSDictionary * scoop= @{@"titulo" : self.titleText.text, @"noticia" : self.boxNews.text, @"filename":[[stringUUID lowercaseString] stringByAppendingPathExtension:@"jpg"]};
    [news insert:scoop
      completion:^(NSDictionary *item, NSError *error) {
          
          if (error) {
              NSLog(@"Error %@", error);
          } else {
              
              NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"barney.gif"], 90);
              NSString *urlString = [NSString stringWithFormat:@"%@?%@", item[@"imageUri"], item[@"sasQueryString"]];
              NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
              [request setHTTPMethod:@"PUT"];
              [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
              [request setHTTPBody:imageData];
              NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
              
              //[conn start];
              
              _receivedData = [[NSMutableData alloc] init];
              [_receivedData setLength:0];
             
              
              NSLog(@"OK");
          }
          
      }];
}


#pragma NSUrlConnectionDelegate Methods

-(void)connection:(NSConnection*)conn didReceiveResponse:
(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] >= 400) {
        NSLog(@"Status Code: %li", (long)[httpResponse statusCode]);
        NSLog(@"Remote url returned error %ld %@",(long)[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    }
    else {
        NSLog(@"Safe Response Code: %li", (long)[httpResponse statusCode]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:
(NSData *)data
{
    [_receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:
(NSError *)error
{
    //We should do something more with the error handling here
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:
           NSURLErrorFailingURLStringErrorKey]);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
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

#pragma mark - Login

- (void)loginUser{
    [self loginAppInViewController:self withCompletion:^(NSArray *results) {
        NSLog(@"Resultados ---> %@", results);
    }];
}

- (void)loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    [self loadUserAuthInfo];
    if( client.currentUser){
        [client invokeAPI:@"getcurrentuserinfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            
            //tenemos info extra del usuario
            if (error == nil){
                NSLog(@"%@", result);
                self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            }else{
                [self loginWithFacebookController:controller withCompletion:bloque];
            }
            
        }];

        return;
    }
    [self loginWithFacebookController:controller withCompletion:bloque];
}

- (void)loginWithFacebookController:(UIViewController*)controller withCompletion:(completeBlock)bloque
{
    [client loginWithProvider:@"facebook"
                   controller:controller
                     animated:YES
                   completion:^(MSUser *user, NSError *error) {
                       
                       if (error) {
                           NSLog(@"Error en el login : %@", error);
                           bloque(nil);
                       } else {
                           NSLog(@"user -> %@", user);
                           
                           [self saveAuthInfo];
                           [client invokeAPI:@"getcurrentuserinfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                               
                               //tenemos info extra del usuario
                               NSLog(@"%@", result);
                               self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                               
                           }];
                           
                           bloque(@[user]);
                       }
                   }];

}


- (BOOL)loadUserAuthInfo{            
    userFBId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    tokenFB = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
    
    if (userFBId) {
        client.currentUser = [[MSUser alloc]initWithUserId:userFBId];
        client.currentUser.mobileServiceAuthenticationToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
        return TRUE;
    }
    
    return FALSE;
}


- (void) saveAuthInfo{
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.userId forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
}

/*
 NSMutableDictionary *dict = [@{} mutableCopy];
 dict[@"parameter1"] = @"value1";
 dict[@"parameter2"] = @"value2";
 
 //if( client.currentUser){
 [client invokeAPI:@"miprimeracustomapi" body:nil HTTPMethod:@"POST" parameters:dict headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
 //tenemos info extra del usuario
 NSLog(@"%@", result);
 
 }];
 
 */






@end
