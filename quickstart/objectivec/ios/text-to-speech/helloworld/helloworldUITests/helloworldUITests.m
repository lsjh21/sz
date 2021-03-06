//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
//

#import <XCTest/XCTest.h>

@interface helloworldUITests : XCTestCase {
    XCUIApplication *app;
}

@end

@implementation helloworldUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    app = [[XCUIApplication alloc] init];
    [app launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSynthesis {
    // sleep to make sure elements are there
    [NSThread sleepForTimeInterval:1];
    
    XCUIElement *inputTextField = app.textFields[@"input_text_field"];
    XCTAssert(inputTextField.exists);
    [inputTextField tap];
    [inputTextField typeText:@"I have a dream."];
    
    XCUIElement *synthButton = app.buttons[@"synthesis_button"];
    XCTAssert(synthButton.exists);
    
    XCUIElement *resultLabel = app.staticTexts[@"result_label"];
    XCTAssert(resultLabel.exists);
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"label == %@", @"The synthesis was completed."];
    
    [self expectationForPredicate:pred evaluatedWithObject:resultLabel handler:nil];
    
    [synthButton tap];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
