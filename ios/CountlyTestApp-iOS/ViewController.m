// ViewController.h
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "ViewController.h"
#import "TestViewControllerModal.h"
#import "TestViewControllerPushPop.h"
#import "Countly.h"
#import "EYLogViewer.h"

@interface ViewController ()
{
    dispatch_queue_t q[8];
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_main;
@end

typedef enum : NSUInteger
{
    TestSectionCustomEvents,
    TestSectionCrashReporting,
    TestSectionUserDetails,
    TestSectionAPM,
    TestSectionViewTracking,
    TestSectionPushNotifications,
    TestSectionMultiThreading,
    TestSectionOthers
} TestSection;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //copy pictures from App Bundle to Documents directory, to use later for User Details picture upload tests.
    NSURL* documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;

    NSArray *fileTypes = @[@"gif",@"jpg",@"png"];
    [fileTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSURL* bundleFileURL = [NSBundle.mainBundle URLForResource:@"SamplePicture" withExtension:((NSString*)obj).lowercaseString];
        NSURL* destinationURL = [documentsDirectory URLByAppendingPathComponent:bundleFileURL.lastPathComponent];
        [NSFileManager.defaultManager copyItemAtURL:bundleFileURL toURL:destinationURL error:nil];
    }];
    
    [self.tbl_main reloadData];
    
    NSInteger startSection = TestSectionCustomEvents; //start section of testing app can be set here.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self.tbl_main scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:startSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark -

- (IBAction)onClick_console:(id)sender
{
    static bool isHidden = NO;
    
    isHidden = !isHidden;

    if(isHidden)
        [EYLogViewer hide];
    else
        [EYLogViewer show];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tests][section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self sections][section];
}


-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    ((UITableViewHeaderFooterView*)view).backgroundView.backgroundColor = UIColor.grayColor;
    ((UITableViewHeaderFooterView*)view).textLabel.textColor = UIColor.whiteColor;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kCountlyCellIdentifier = @"kCountlyCellIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCountlyCellIdentifier];
    
    if(!cell)
    {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCountlyCellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:14];
    }

    cell.textLabel.text = [self tests][indexPath.section][indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Test: %@ - %@",[self sections][indexPath.section],[self tests][indexPath.section][indexPath.row]);

    switch (indexPath.section)
    {
#pragma mark Custom Events
        case TestSectionCustomEvents:
        {
            switch (indexPath.row)
            {
                case 0: [Countly.sharedInstance recordEvent:@"button-click"];
                break;

                case 1: [Countly.sharedInstance recordEvent:@"button-click" count:5];
                break;

                case 2: [Countly.sharedInstance recordEvent:@"button-click" sum:1.99];
                break;

                case 3: [Countly.sharedInstance recordEvent:@"button-click" duration:3.14];
                break;

                case 4: [Countly.sharedInstance recordEvent:@"button-click" segmentation:@{@"k" : @"v"}];
                break;

                case 5: [Countly.sharedInstance recordEvent:@"button-click" segmentation:@{@"k" : @"v"} count:5];
                break;

                case 6: [Countly.sharedInstance recordEvent:@"button-click" segmentation:@{@"k" : @"v"} count:5 sum:1.99];
                break;

                case 7: [Countly.sharedInstance recordEvent:@"button-click" segmentation:@{@"k" : @"v"} count:5 sum:1.99 duration:0.314];
                break;

                case 8: [Countly.sharedInstance startEvent:@"timed-event"];
                break;

                case 9: [Countly.sharedInstance endEvent:@"timed-event" segmentation:@{@"k" : @"v"} count:1 sum:0];
                break;

                default:break;
            }
        }
        break;


#pragma mark Crash Reporting
        case TestSectionCrashReporting:
        {
            switch (indexPath.row)
            {
                case 0:[CountlyCrashReporter.sharedInstance crashTest];
                break;

                case 1:[CountlyCrashReporter.sharedInstance crashTest2];
                break;

                case 2:[CountlyCrashReporter.sharedInstance crashTest3];
                break;

                case 3:[CountlyCrashReporter.sharedInstance crashTest4];
                break;

                case 4:[CountlyCrashReporter.sharedInstance crashTest5];
                break;

                case 5:[CountlyCrashReporter.sharedInstance crashTest6];
                break;

                case 6:
                {
                    [Countly.sharedInstance crashLog:@"This is a custom crash log!"];
                    [Countly.sharedInstance crashLog:@"This is another custom crash log with argument: %d!", 2];
                }break;

                case 7:
                {
                    NSException* myException = [NSException exceptionWithName:@"MyException" reason:@"MyReason" userInfo:@{@"key":@"value"}];
                    [Countly.sharedInstance recordHandledException:myException];
                }break;

                default: break;
            }
        }
        break;


#pragma mark User Details
        case TestSectionUserDetails:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    NSURL* documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
                    NSString* localImagePath = [documentsDirectory.absoluteString stringByAppendingPathComponent:@"SamplePicture.jpg"];
                    // SamplePicture.png or SamplePicture.gif can be used too.

                    Countly.user.name = @"John Doe";
                    Countly.user.email = @"john@doe.com";
                    Countly.user.birthYear = @(1970);
                    Countly.user.organization = @"United Nations";
                    Countly.user.gender = @"M";
                    Countly.user.phone = @"+0123456789";
                    //Countly.user.pictureURL = @"http://s12.postimg.org/qji0724gd/988a10da33b57631caa7ee8e2b5a9036.jpg";
                    Countly.user.pictureLocalPath = localImagePath;
                    Countly.user.custom = @{@"testkey1":@"testvalue1",@"testkey2":@"testvalue2"};

                    [Countly.user recordUserDetails];
                }break;

                case 1:
                {
                    [Countly.user set:@"key101" value:@"value101"];
                    [Countly.user incrementBy:@"key102" value:5];
                    [Countly.user push:@"key103" value:@"singlevalue"];
                    [Countly.user push:@"key104" values:@[@"first",@"second",@"third"]];
                    [Countly.user push:@"key105" values:@[@"a",@"b",@"c",@"d"]];
                    [Countly.user save];
                }break;

                case 2:
                {
                    [Countly.user multiply:@"key102" value:2];
                    [Countly.user unSet:@"key103"];
                    [Countly.user pull:@"key104" value:@"second"];
                    [Countly.user pull:@"key105" values:@[@"a",@"d"]];
                    [Countly.user save];
                }break;

                case 3: [Countly.sharedInstance userLoggedIn:@"OwnUserID"];
                break;

                case 4: [Countly.sharedInstance userLoggedOut];
                break;

                default:break;
            }
        }
        break;


#pragma mark APM
        case TestSectionAPM:
        {
            NSString* urlString = @"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json";
        //    NSString* urlString = @"http://www.bbc.co.uk/radio1/playlist.json";
        //    NSString* urlString = @"https://maps.googleapis.com/maps/api/geocode/json?address=Ebisu%20Garden%20Place,Tokyo";
        //    NSString* urlString = @"https://itunes.apple.com/search?term=Michael%20Jackson&entity=musicVideo";

            NSURL* URL = [NSURL URLWithString:urlString];
            NSMutableURLRequest* request= [NSMutableURLRequest requestWithURL:URL];

            NSURLResponse* response;
            NSError* error;

            switch (indexPath.row)
            {
                case 0: [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                break;

                case 1: [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueue.mainQueue completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError)
                        {
                            NSLog(@"sendAsynchronousRequest:queue:completionHandler: finished!");
                        }];
                break;

                case 2: [NSURLConnection connectionWithRequest:request delegate:self];
                break;

                case 3:
                {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wunused-variable"
                    NSURLConnection* testConnection = [NSURLConnection.alloc initWithRequest:request delegate:self];
                    #pragma clang diagnostic push
                }break;

                case 4:
                {
                    NSURLConnection * testConnection = [NSURLConnection.alloc initWithRequest:request delegate:self startImmediately:NO];
                    [testConnection start];
                }break;

                case 5:
                {
                    NSURLConnection * testConnection = [NSURLConnection.alloc initWithRequest:request delegate:self startImmediately:YES];
                }break;
                
                case 6:
                {
                    NSURLSessionDataTask* testTask = [NSURLSession.sharedSession dataTaskWithRequest:request];
                    [testTask resume];
                }break;
                
                case 7:
                {
                    NSURLSessionDataTask* testTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                    {
                        NSLog(@"dataTaskWithRequest:completionHandler: finished!");
                    }];
                    [testTask resume];
                }break;
                
                case 8:
                {
                    NSURLSessionDataTask* testTask = [NSURLSession.sharedSession dataTaskWithURL:URL];
                    [testTask resume];
                }break;

                case 9:
                {
                    NSURLSessionDataTask* testTask = [NSURLSession.sharedSession dataTaskWithURL:URL completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                    {
                        NSLog(@"dataTaskWithURL:completionHandler: finished!");
                    }];
                    [testTask resume];
                }break;

                case 10:
                {
                    NSURLSessionDownloadTask* testTask = [NSURLSession.sharedSession downloadTaskWithRequest:request];
                    [testTask resume];
                }break;
                
                case 11:
                {
                    NSURLSessionDownloadTask* testTask = [NSURLSession.sharedSession downloadTaskWithRequest:request completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error)
                    {
                        NSLog(@"dataTaskWithRequest:completionHandler: finished!");
                    }];
                    [testTask resume];
                }break;
                
                case 12:
                {
                    NSURLSessionDownloadTask* testTask = [NSURLSession.sharedSession downloadTaskWithURL:URL];
                    [testTask resume];
                }break;

                case 13:
                {
                    NSURLSessionDownloadTask* testTask = [NSURLSession.sharedSession downloadTaskWithURL:URL completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error)
                    {
                        NSLog(@"dataTaskWithURL:completionHandler: finished!");
                    }];
                    [testTask resume];
                }break;

                case 14: [Countly.sharedInstance addExceptionForAPM:@"http://finance.yahoo.com"];
                break;

                case 15: [Countly.sharedInstance removeExceptionForAPM:@"http://finance.yahoo.com"];
                break;

                default:break;
            }
        }
        break;


#pragma mark View Tracking
        case TestSectionViewTracking:
        {
            switch (indexPath.row)
            {
                case 0: Countly.sharedInstance.isAutoViewTrackingEnabled = NO;
                break;

                case 1: Countly.sharedInstance.isAutoViewTrackingEnabled = YES;
                break;

                case 2:
                {
                    TestViewControllerModal* testViewControllerModal = [TestViewControllerModal.alloc initWithNibName:@"TestViewControllerModal" bundle:nil];
                    [self presentViewController:testViewControllerModal animated:YES completion:nil];
                }break;

                case 3:
                {
                    TestViewControllerPushPop* testViewControllerPushPop = [TestViewControllerPushPop.alloc initWithNibName:@"TestViewControllerPushPop" bundle:nil];
                    UINavigationController* nc = [UINavigationController.alloc initWithRootViewController:testViewControllerPushPop];
                    nc.title = @"TestViewControllerPushPop";
                    [self presentViewController:nc animated:YES completion:nil];
                }break;

                case 4: [Countly.sharedInstance addExceptionForAutoViewTracking:TestViewControllerModal.class];
                break;

                case 5: [Countly.sharedInstance removeExceptionForAutoViewTracking:TestViewControllerModal.class];
                break;

                case 6: [Countly.sharedInstance reportView:@"ManualViewReportExample_MyMainView"];
                break;

                default: break;
            }
        }
        break;


#pragma mark Push Notifications
        case TestSectionPushNotifications:
        {
            switch (indexPath.row)
            {
                case 0: [Countly.sharedInstance askForNotificationPermission];
                break;

                case 1:
                {
                    UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
                    [Countly.sharedInstance askForNotificationPermissionWithOptions:authorizationOptions completionHandler:^(BOOL granted, NSError *error)
                    {
                        
                    }];
                }break;

                case 2: [Countly.sharedInstance recordLocation:(CLLocationCoordinate2D){33.6789,43.1234}];
                break;

                default: break;
            }
        }
        break;


#pragma mark Multi Threading
        case TestSectionMultiThreading:
        {
            NSInteger t = indexPath.row;
            NSString* tag = @(t).description;
            NSString* commonQueueName = @"ly.count.multithreading";
            NSString* queueName = [commonQueueName stringByAppendingString:tag];

            if(!q[t])
                q[t] = dispatch_queue_create([queueName UTF8String], NULL);

            for (int i=0; i<15; i++)
            {
                NSString* eventName = [@"MultiThreadingEvent" stringByAppendingString:tag];
                NSDictionary* segmentation = @{@"k":[@"v"stringByAppendingString:@(i).description]};
                dispatch_async( q[t], ^{ [Countly.sharedInstance recordEvent:eventName segmentation:segmentation]; });
            }
        }
        break;


#pragma mark Others
        case TestSectionOthers:
        {
            switch (indexPath.row)
            {
                case 0: [Countly.sharedInstance setCustomHeaderFieldValue:@"thisismyvalue"];
                break;

                case 1: [Countly.sharedInstance askForStarRating:^(NSInteger rating){ NSLog(@"rating %d",(int)rating); }];
                break;

                case 2: [Countly.sharedInstance setNewDeviceID:@"user@example.com" onServer:NO];
                break;

                case 3: [Countly.sharedInstance setNewDeviceID:CLYIDFV onServer:YES];
                break;

                default: break;
            }
        }
        break;
        
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (NSArray *)sections
{
    static NSArray* sections;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sections =  @[@"Custom Events",
                      @"Crash Reporting",
                      @"User Details",
                      @"APM",
                      @"View Tracking",
                      @"Push Notifications",
                      @"Multi Threading",
                      @"Others"];
    });
    
    return sections;
}


- (NSArray *)tests
{
    static NSArray* tests;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        tests = @[
                  @[@"record event",
                    @"record event with count",
                    @"record event with sum",
                    @"record event with duration",
                    @"record event with segm.",
                    @"record event with segm. & count",
                    @"record event with segm. count & sum",
                    @"record event with segm. count, sum & dur.",
                    @"start event",
                    @"end event",
                    @"end event with segm. count & sum"],
    
                  @[@"unrecognized selector",
                    @"out of bounds",
                    @"NULL pointer",
                    @"invalid geometry",
                    @"assert fail",
                    @"kill",
                    @"custom crash log",
                    @"record handled exception"],
    
                  @[@"record user details",
                    @"custom modifiers 1",
                    @"custom modifiers 2",
                    @"user logged in",
                    @"user logged out"],
    
                  @[@"sendSynchronous",
                    @"sendAsynchronous",
                    @"connectionWithRequest",
                    @"initWithRequest",
                    @"initWithRequest startImmediately NO",
                    @"initWithRequest startImmediately YES",
                    @"dataTaskWithRequest",
                    @"dataTaskWithRequest:completionHandler",
                    @"dataTaskWithURL",
                    @"dataTaskWithURL:completionHandler",
                    @"downloadTaskWithRequest",
                    @"downloadTaskWithRequest:completionHandler",
                    @"downloadTaskWithURL",
                    @"downloadTaskWithURL:completionHandler",
                    @"add exception",
                    @"remove exception"],
    
                  @[@"turn off auto",
                    @"turn on auto",
                    @"present modal",
                    @"navigation controller push / pop",
                    @"add exception",
                    @"remove exception",
                    @"manual report"],
    
                  @[@"ask for notification permission",
                    @"ask for notification permission with completion handler",
                    @"record location"],
    
                  @[@"thread 1",
                    @"thread 2",
                    @"thread 3",
                    @"thread 4",
                    @"thread 5",
                    @"thread 6",
                    @"thread 7",
                    @"thread 8"],
    
                  @[@"set custom header field value",
                    @"ask for star-rating",
                    @"set new device id",
                    @"set new device id with server merge"]];
    });
    
    return tests;
}

#pragma mark -

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    NSLog(@"%s %@",__FUNCTION__,[connection description]);
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"%s %@",__FUNCTION__,[connection description]);
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSLog(@"%s %@",__FUNCTION__,[connection description]);
}

@end
