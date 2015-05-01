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
#import "MBProgressHUD.h"

@interface ScoopManagerViewController (){
    
    MSClient * client;
    NSString *userName;
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
@property (weak, nonatomic) IBOutlet UIImageView *imageTook;
@property (strong, nonatomic) MBProgressHUD *hud;


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
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self requestWhenInUseAuthorization];
    
    [self updateLocalization];
    self.localizationTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                              target:self
                                                            selector:@selector(updateLocalization)
                                                            userInfo:nil
                                                             repeats:YES];
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



#pragma mark - actions

- (IBAction)addNew:(id)sender {
    if( client.currentUser){
        [self addNewToAzure];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not logged In" message:@"You are not currently logged in. We'll try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self loginWithFacebookController:self withCompletion:^(NSArray *results) { }];
    }
}


- (IBAction)takePhoto:(id)sender {
    UIImagePickerController  *picker = [UIImagePickerController new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate = self;
    
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:picker
                       animated:YES
                     completion:^{ }];
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

#pragma mark - Login

- (void)loginUser{
    [self loginAppInViewController:self withCompletion:^(NSArray *results) {
        NSLog(@"Resultados ---> %@", results);
    }];
}

- (void)loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    [self loadUserAuthInfo];
    if( client.currentUser){
        [self getUserInfo:YES controller:controller bloque:bloque];
        
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
                           if (bloque != nil)
                               bloque(nil);
                       } else {
                           NSLog(@"user -> %@", user);
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_IN" object:self userInfo:@{@"client":client}];
                           [self saveAuthInfo];
                           [self getUserInfo:NO controller:controller bloque:bloque];
                           if (bloque != nil)
                               bloque(@[user]);
                       }
                   }];

}

- (void)getUserInfo:(BOOL)previousError controller:(UIViewController*)controller bloque:(completeBlock)bloque
{
   
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.detailsLabelText = @"Loading user info";
    [self.hud show:YES];
    [client invokeAPI:@"getcurrentuserinfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if (error == nil){
            //tenemos info extra del usuario
            NSLog(@"%@", result);
            self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            userName = result[@"name"];
            if (previousError)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_IN" object:self userInfo:@{@"client":client}];
            [self.hud hide:YES];
        }else{
            if (previousError)
                [self loginWithFacebookController:controller withCompletion:bloque];
            [self.hud hide:YES];            
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


#pragma mark - Azure connect, setup, login etc...

-(void)warmupMSClient{
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", client.debugDescription);
}

- (void)addNewToAzure{
    
    MSTable *news = [client tableWithName:@"news"];
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    NSDictionary * scoop= @{@"titulo" : self.titleText.text,
                            @"noticia" : self.boxNews.text,
                            @"filename":[[stringUUID lowercaseString] stringByAppendingPathExtension:@"jpg"],
                            @"autor":userName,
                            @"longitud": (self.location==nil)?@"":@(self.location.coordinate.longitude),
                            @"latitud": (self.location==nil)?@"":@(self.location.coordinate.latitude)};
    [news insert:scoop
      completion:^(NSDictionary *item, NSError *error) {
          if (error) {
              self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
              self.hud.mode = MBProgressHUDModeText;
              self.hud.detailsLabelText = error.userInfo[@"NSLocalizedDescription"];
              [self.hud show:YES];
              [self.hud hide:YES afterDelay:2];

              
              NSLog(@"Error %@", error);
          } else {
              if (self.imageTook.image){
                  //Redimensionar imagen
                  NSData *imageData = [self getDataAndResizeImage:self.imageTook.image];
                  NSString *urlString = [NSString stringWithFormat:@"%@?%@", item[@"imageUri"], item[@"sasQueryString"]];
                  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                  [request setHTTPMethod:@"PUT"];
                  [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
                  [request setHTTPBody:imageData];
                  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                  [conn start];
                  _receivedData = [[NSMutableData alloc] init];
                  [_receivedData setLength:0];
              }else{
              }
              self.titleText.text = @"";
              self.boxNews.text = @"";
              self.imageTook.image = nil;
              NSLog(@"OK");
              [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOULD_REFRESH_DATA" object:self];

          }
      }];
    
    
    
}


#pragma mark - NSURLConnectionDelegate Methods

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


#pragma mark -  UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES
                             completion:^{ }];
    self.imageTook.image = img;
}


#pragma mark - Utils
- (NSData*)getDataAndResizeImage:(UIImage*)actualImage
{
    UIGraphicsBeginImageContext(CGSizeMake(actualImage.size.width/2, actualImage.size.height/2));
    [actualImage drawInRect:CGRectMake(0,0,actualImage.size.width/2, actualImage.size.height/2)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *smallData = UIImagePNGRepresentation(newImage);
    return smallData;
}


#pragma mark - CoreLocation
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
    [self performSelector:@selector(stopTracking) withObject:nil afterDelay:5];
}

#pragma mark - Active Localization

- (void)updateLocalization{
    [self.locationManager startUpdatingLocation];
}

- (void)stopTracking
{
    [self.locationManager stopUpdatingLocation];

}


- (void)requestWhenInUseAuthorization
{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusDenied) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Not acccepted"
                                                                message:@"Please active location in settings"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

@end
