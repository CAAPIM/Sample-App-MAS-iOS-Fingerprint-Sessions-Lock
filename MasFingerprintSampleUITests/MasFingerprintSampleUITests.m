//
//  MasFingerprintSampleUITests.m
//  MasFingerprintSampleUITests
//
//  Created by Ashwin Kumar on 22/12/21.
//  Copyright © 2021 Ca Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>

#define KEY_LABEL_PERMISSIONS_ALLOW_BUTTON @"label.permissions.allow.button"
#define KEY_INTERRUPT_MONITOR_DESCRIPTION @"interrupt.monitor.description"
#define KEY_LABEL_LOGIN_BUTTON @"label.login.button"
#define KEY_LABEL_FETCH_BUTTON @"label.fetch.button"
#define KEY_LABEL_LOCK_BUTTON @"label.lock.button"
#define KEY_LABEL_UNLOCK_BUTTON @"label.unlock.button"
#define KEY_TEXT_LOGGED_IN @"text.logged.in"
#define KEY_TEXT_RED_STAPLER @"text.red.stapler"

#define SAMPLE_USER_NAME @"admin"
#define SAMPLE_USER_PASSWORD @"7layer"

#define LOGIN_USER_NAME_FIELD @"masui-usernameField"
#define LOGIN_PASSWORD_FIELD @"masui-passwordField"

@interface MasFingerprintSampleUITests : XCTestCase

@property(nonatomic,strong) NSDictionary *externalStringsDict;

@end

@implementation MasFingerprintSampleUITests

- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ui_tests_config" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return NO;
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    _externalStringsDict = [self JSONFromFile];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (XCUIApplication*) initializeApp {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    NSString *allowBtnText = [_externalStringsDict objectForKey:KEY_LABEL_PERMISSIONS_ALLOW_BUTTON];
    [self addUIInterruptionMonitorWithDescription:[_externalStringsDict objectForKey:KEY_INTERRUPT_MONITOR_DESCRIPTION] handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {

        // handling permissions popup
        XCUIElementQuery * buttons = interruptingElement.buttons;
        XCUIElement * allowPermissionsBtn = buttons[allowBtnText];
        if ([allowPermissionsBtn exists]) {
            [allowPermissionsBtn tap];
            return YES;
        }

        XCTAssert(NO);
        return NO;
    }];
    return app;
}

- (void)testLockUnlockSession {
    XCUIApplication *app = [self initializeApp];
    [app launch];
    [app swipeUp];
    
    // login if MainViewController is shown
    XCUIElement * loginButton = app.staticTexts[[_externalStringsDict objectForKey:KEY_LABEL_LOGIN_BUTTON]];
    BOOL result = [loginButton waitForExistenceWithTimeout:5];
    if (result) {
        [loginButton tap];

        XCUIElementQuery *elementsQuery = app.scrollViews.otherElements;
        XCUIElement * userNameField = elementsQuery.textFields[LOGIN_USER_NAME_FIELD];
        result = [userNameField waitForExistenceWithTimeout:20];
        XCTAssert(result);
        [userNameField tap];
        [userNameField typeText:SAMPLE_USER_NAME];
        XCUIElement * userPasswordField = elementsQuery.secureTextFields[LOGIN_PASSWORD_FIELD];
        [userPasswordField tap];
        [userPasswordField typeText:SAMPLE_USER_PASSWORD];
        [elementsQuery.staticTexts[[_externalStringsDict objectForKey:KEY_LABEL_LOGIN_BUTTON]] tap];
    }
    XCUIElement * loggedInText = app.staticTexts[[_externalStringsDict objectForKey:KEY_TEXT_LOGGED_IN]];
    result = [loggedInText waitForExistenceWithTimeout:20];

    // call protected resource by tapping Fetch button
    XCUIElement * fetchButton = app.staticTexts[[_externalStringsDict objectForKey:KEY_LABEL_FETCH_BUTTON]];
    [fetchButton tap];
    XCUIElementQuery *tablesQuery = [[XCUIApplication alloc] init].tables;
    
    // verify whether data is pulled successfully
    result = [tablesQuery.staticTexts[[_externalStringsDict objectForKey:KEY_TEXT_RED_STAPLER]]  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // lock the session
    XCUIElement * lockButton = app.staticTexts[[_externalStringsDict objectForKey:KEY_LABEL_LOCK_BUTTON]];
    [lockButton tap];
    XCUIElement * unLockButton = app.staticTexts[[_externalStringsDict objectForKey:KEY_LABEL_UNLOCK_BUTTON]];
    result = [unLockButton  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // pull protected resource by tapping Fetch button
    [fetchButton tap];
    
    // data shouldn't be rendered as the fetching protected resource fails
    result = [tablesQuery.staticTexts[[_externalStringsDict objectForKey:KEY_TEXT_RED_STAPLER]]  waitForExistenceWithTimeout:10];
    XCTAssert(!result);
    
    // unlock the session
    [unLockButton tap];
    result = [lockButton  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // pull protected resource by tapping Fetch button
    [fetchButton tap];
    result = [tablesQuery.staticTexts[[_externalStringsDict objectForKey:KEY_TEXT_RED_STAPLER]]  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    /* [XCUIDevice.sharedDevice pressButton:XCUIDeviceButtonHome];
    [app waitForState:XCUIApplicationStateRunningBackground timeout:5];
    [app activate];
    
    result = [app.staticTexts[@"Logged-in as: admin"]  waitForExistenceWithTimeout:10];
    XCTAssert(result); */
}

- (void)testLaunchPerformance {
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *)) {
        // This measures how long it takes to launch your application.
        [self measureWithMetrics:@[[[XCTApplicationLaunchMetric alloc] init]] block:^{
            [[[XCUIApplication alloc] init] launch];
        }];
    }
}

@end
