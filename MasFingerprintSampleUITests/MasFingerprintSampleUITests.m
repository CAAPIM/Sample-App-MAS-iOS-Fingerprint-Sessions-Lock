//
//  MasFingerprintSampleUITests.m
//  MasFingerprintSampleUITests
//
//  Created by Ashwin Kumar on 22/12/21.
//  Copyright © 2021 Ca Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>

#define APP_PERMISSIONS_LABEL @"Allow While Using App"
#define INTERRUPTION_MONITOR_DESCRIPTION @"TestInitialScreenHandler"
#define LOGIN_BUTTON_LABEL @"Login"
#define USER_NAME @"admin"
#define ADMIN_PASSWORD @"autotest"
#define LOGIN_USER_NAME_FIELD @"masui-usernameField"
#define LOGIN_PASSWORD_FIELD @"masui-passwordField"
#define FETCH_BUTTON_LABEL @"Fetch"
#define LOCK_BUTTON_LABEL @"Lock"
#define UNLOCK_BUTTON_LABEL @"Unlock"
#define LOGGED_IN_TEXT @"Logged In"
#define RED_STAPLER @"Red Stapler"

@interface MasFingerprintSampleUITests : XCTestCase

@end

@implementation MasFingerprintSampleUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (XCUIApplication*) initializeApp {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:INTERRUPTION_MONITOR_DESCRIPTION handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {

        // handling permissions popup
        XCUIElementQuery * buttons = interruptingElement.buttons;
        XCUIElement * allowPermissionsBtn = buttons[APP_PERMISSIONS_LABEL];
        if ([allowPermissionsBtn exists]) {
            [allowPermissionsBtn tap];
            return YES;
        }

        XCTAssert(NO);
        return NO;
    }];
    return app;
}

- (void)testInitialScreen {
    XCUIApplication *app = [self initializeApp];
    [app launch];
    [app swipeUp];
    
    // login if MainViewController is shown
    XCUIElement * loginButton = app.staticTexts[LOGIN_BUTTON_LABEL];
    BOOL result = [loginButton waitForExistenceWithTimeout:5];
    if (result) {
        [loginButton tap];

        XCUIElementQuery *elementsQuery = app.scrollViews.otherElements;
        XCUIElement * userNameField = elementsQuery.textFields[LOGIN_USER_NAME_FIELD];
        [userNameField tap];
        [userNameField typeText:USER_NAME];
        XCUIElement * userPasswordField = elementsQuery.secureTextFields[LOGIN_PASSWORD_FIELD];
        [userPasswordField tap];
        [userPasswordField typeText:ADMIN_PASSWORD];
        [elementsQuery.staticTexts[LOGIN_BUTTON_LABEL] tap];
    }
    XCUIElement * loggedInText = app.staticTexts[LOGGED_IN_TEXT];
    result = [loggedInText waitForExistenceWithTimeout:20];

    // call protected resource by tapping Fetch button
    XCUIElement * fetchButton = app.staticTexts[FETCH_BUTTON_LABEL];
    [fetchButton tap];
    XCUIElementQuery *tablesQuery = [[XCUIApplication alloc] init].tables;
    
    // verify whether data is pulled successfully
    result = [tablesQuery.staticTexts[RED_STAPLER]  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // lock the session
    XCUIElement * lockButton = app.staticTexts[LOCK_BUTTON_LABEL];
    [lockButton tap];
    XCUIElement * unLockButton = app.staticTexts[UNLOCK_BUTTON_LABEL];
    result = [unLockButton  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // pull protected resource by tapping Fetch button
    [fetchButton tap];
    
    // data shouldn't be rendered as the fetching protected resource fails
    result = [tablesQuery.staticTexts[RED_STAPLER]  waitForExistenceWithTimeout:10];
    XCTAssert(!result);
    
    // unlock the session
    [unLockButton tap];
    result = [lockButton  waitForExistenceWithTimeout:10];
    XCTAssert(result);
    
    // pull protected resource by tapping Fetch button
    [fetchButton tap];
    result = [tablesQuery.staticTexts[RED_STAPLER]  waitForExistenceWithTimeout:10];
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
