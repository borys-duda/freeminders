//
//  InterpreterTests.m
//  Freeminders
//
//  Created by Developer on 1/20/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TimeSpan.h"

#import "Interpreter.h"
#import "InterpreterAdapter.h"

@interface InterpreterAdapterTest : InterpreterAdapter

// Allow the test cases to implement this block to force a return value
// that is different from the default value
@property (nonatomic, copy)NSObject *(^getValue)(void);

// Allow the test cases to implement this block to interrogate
// the callback args
@property (nonatomic, copy)void(^onQueryDate)(QueryDateCallbackArgs *args);
@property (nonatomic, copy)void(^onQueryTime)(QueryTimeCallbackArgs *args);
@property (nonatomic, copy)void(^onQueryString)(QueryStringCallbackArgs *args);
@property (nonatomic, copy)void(^onQueryInteger)(QueryIntegerCallbackArgs *args);

@end

@implementation InterpreterAdapterTest

- (void)queryDate:(QueryDateCallbackArgs *)args {
    if (self.onQueryDate) self.onQueryDate(args);
    self.selectionChanged(self.getValue ? self.getValue() : args.val);
}

- (void)queryTime:(QueryTimeCallbackArgs *)args {
    if (self.onQueryTime) self.onQueryTime(args);
    self.selectionChanged(self.getValue ? self.getValue() : args.val);
}

- (void)queryString:(QueryStringCallbackArgs *)args {
    if (self.onQueryString) self.onQueryString(args);
    self.selectionChanged(self.getValue ? self.getValue() : args.val);
}

- (void)queryInteger:(QueryIntegerCallbackArgs *)args {
    if (self.onQueryInteger) self.onQueryInteger(args);
    self.selectionChanged(self.getValue ? self.getValue() : args.val);
}

@end


@interface InterpreterTests : XCTestCase
@end

@implementation InterpreterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_Set_New_Current_Date {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [[NSDate date] dateOnly];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New([date])";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

-(void)test_Set_New_Current_Time {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            TimeSpan *obj = (TimeSpan *)[[Interpreter instance].variables objectForKey:@"F"];
            TimeSpan *control = [[NSDate date] timeOnly];
            
            // Allow it to be off by 1 second. This could probably be shrunk down, but the second *could* tick
            // between the executeScript line and the control line.
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReference], [obj timeIntervalSinceReference], 1, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New([time])";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

-(void)test_Set_New_Current_DateTime {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [NSDate date];
            
            // Allow it to be off by 1 second. This could probably be shrunk down, but the second *could* tick
            // between the executeScript line and the control line.
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 1, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New([now])";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_New_Date {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [NSDate year:2015 month:7 day:1 hour:0 minutes:0 seconds:0];
            
            // Allow it to be off by 1 second. This could probably be shrunk down, but the second *could* tick
            // between the executeScript line and the control line.
           XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 7, 1)";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_New_Date_Variables {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [NSDate year:2015 month:2 day:2 hour:0 minutes:0 seconds:0];
            
            // Allow it to be off by 1 second. This could probably be shrunk down, but the second *could* tick
            // between the executeScript line and the control line.
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET Y = New(int, 2015)\n"
                        "SET M = New(int, 2)\n"
                        "SET D = New(int, 2)\n"
                        "SET F = New(date, Y, M, D)";
                        
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_New_Time {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            TimeSpan *obj = (TimeSpan *)[[Interpreter instance].variables objectForKey:@"F"];
            TimeSpan *control = [TimeSpan hours:13 minutes:27 seconds:1];
            
            XCTAssertTrue([obj isEqual: control], @"TimeSpans are not equal");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(time, 13, 27, 1)";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_New_Integer {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:42];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(int, 42)";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_New_String {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSString *obj = (NSString *)[[Interpreter instance].variables objectForKey:@"F"];
            NSString *control = @"Hello World\tHow are Ya?";
            
            XCTAssertTrue([obj isEqualToString: control], @"Strings are not equal %@ %@", control, obj);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(string, 'Hello World\\tHow are Ya?')";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_Val {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [NSDate year:2015 month:2 day:1 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1)\n"
                        "SET F = Val(D)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Year {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:2015];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'year')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Month {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:2];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'month')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Day {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:1];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'day')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Hour {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:23];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'hour')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Minute {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:30];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'minute')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DatePart_Second {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSNumber *obj = (NSNumber *)[[Interpreter instance].variables objectForKey:@"F"];
            NSNumber *control = [NSNumber numberWithInt:21];
            
            XCTAssertEqual([control integerValue], [obj integerValue]);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = New(date, 2015, 2, 1, 23, 30, 21)\n"
                        "SET F = DatePart(D, 'second')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DateAdd_Add {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2016 month:2 day:3 hour:1 minutes:1 seconds:1];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 2)\n"
                        "SET G = DateAdd(F, 1, 1, 1, 1, 1, 1)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_DateAdd_Subtract {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2013 month:11 day:29 hour:22 minutes:58 seconds:59];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 1)\n"
                        "SET G = DateAdd(F, -1, -1, -1, -1, -1, -1)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_NextDate_SameDate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2015 month:1 day:1 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 1)\n"
                        "SET G = NextDate(F, '1:R', True)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_NextDate_SameDate_Next {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2015 month:1 day:8 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 1)\n"
                        "SET G = NextDate(F, '1:R', False)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_NextDate_Last_Same {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2015 month:1 day:29 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 29)\n"
                        "SET G = NextDate(F, 'L:R', True)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_NextDate_Last_Next {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2015 month:2 day:26 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 29)\n"
                        "SET G = NextDate(F, 'L:R', False)";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_NextDate_FirstOfYear {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"G"];
            NSDate *control = [NSDate year:2015 month:1 day:1 hour:0 minutes:0 seconds:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET F = New(date, 2015, 1, 5)\n"
                        "SET P = DateAdd(F, -1)\n"
                        "SET G = NextDate(P, '01/01')";
    
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_Reminder_Get_Note {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSString *obj = (NSString *)[[Interpreter instance].variables objectForKey:@"F"];
            NSString *control = @"Hello Notes";
            
            XCTAssertTrue([obj isEqualToString: control], @"Strings are not equal %@ %@", control, obj);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    Reminder *r = [Reminder object];
    
    r.key = @"Key1";
    r.note = @"Hello Notes";
    
    NSArray *reminders = [NSArray arrayWithObject: r];
    NSString *script = @"SET F = Reminders[Key1][Note]";
    
    [[Interpreter instance] executeScript:script forReminders:reminders];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_Reminder_Set_Note {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSString *obj = (NSString *)[[Interpreter instance].variables objectForKey:@"F"];
            NSString *control = @"More Notes";
            
            XCTAssertTrue([obj isEqualToString: control], @"Strings are not equal %@ %@", control, obj);
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    Reminder *r = [Reminder object];
    
    r.key = @"Key1";
    r.note = @"Hello Notes";
    
    NSArray *reminders = [NSArray arrayWithObject: r];
    NSString *script = @"Reminders[Key1][Note] = New(string, 'More Notes')\n"
                        "SET F = Reminders[Key1][Note]";
    
    [[Interpreter instance] executeScript:script forReminders:reminders];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_Reminder_Get_Date {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    NSDate *d = [NSDate year:2015 month:1 day:1 hour:5 minutes:13 seconds:10];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [d dateByAddingTimeInterval:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    DateTimeTrigger *dt = [DateTimeTrigger object];
    dt.date = [d dateByAddingTimeInterval:0];
    
    Reminder *r = [Reminder object];
    
    r.key = @"Key1";
    r.triggerType = datetimeTrigger;
    r.dateTimeTriggers = [NSMutableArray arrayWithObject: dt];
    
    NSArray *reminders = [NSArray arrayWithObject: r];
    NSString *script = @"SET F = Reminders[Key1][trigger.Date]";
    
    [[Interpreter instance] executeScript:script forReminders:reminders];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

- (void)test_Set_Reminder_Set_Date {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    NSDate *d = [NSDate year:2015 month:1 day:2 hour:5 minutes:13 seconds:10];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"F"];
            NSDate *control = [d dateByAddingTimeInterval:0];
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    DateTimeTrigger *dt = [DateTimeTrigger object];
    dt.date = [d dateByAddingTimeInterval:0];
    
    Reminder *r = [Reminder object];
    
    r.key = @"Key1";
    r.triggerType = datetimeTrigger;
    r.dateTimeTriggers = [NSMutableArray arrayWithObject: dt];
    
    NSArray *reminders = [NSArray arrayWithObject: r];
    NSString *script = @"Reminders[Key1][trigger.Date] = New(date, 2015, 1, 2, 5, 13, 10)\n"
                        "SET F = Reminders[Key1][trigger.Date]";
    
    [[Interpreter instance] executeScript:script forReminders:reminders];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

-(void)test_Set_Prompt_Date_1 {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    NSDate *newValue = [NSDate year:2025 month:7 day:8 hour:0 minutes:0 seconds:0];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    adapter.getValue = ^(void) {
        return newValue;
    };
    
    adapter.onQueryDate =^(QueryDateCallbackArgs *args) {
        XCTAssertTrue([args.title isEqualToString: @"Choose a date"], @"Strings are not equal");
        XCTAssertTrue([args.message isEqualToString: @"Please enter a date"], @"Strings are not equal");
    };
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"D"];
            NSDate *control = newValue;
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = Prompt(date, 'Choose a date', 'Please enter a date')";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

-(void)test_Set_Prompt_Date_2 {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Interpreter"];
    
    NSDate *defValue = [NSDate year:2015 month:1 day:5 hour:0 minutes:0 seconds:0];
    NSDate *minValue = [NSDate year:2014 month:7 day:6 hour:0 minutes:0 seconds:0];
    NSDate *maxValue = [NSDate year:2026 month:4 day:2 hour:0 minutes:0 seconds:0];
    NSDate *newValue = [NSDate year:2025 month:7 day:8 hour:0 minutes:0 seconds:0];
    
    InterpreterAdapterTest *adapter = [[InterpreterAdapterTest alloc] init];
    
    adapter.getValue = ^(void) {
        return newValue;
    };
    
    adapter.onQueryDate =^(QueryDateCallbackArgs *args) {
        XCTAssertEqualWithAccuracy([defValue timeIntervalSinceReferenceDate], [args.val timeIntervalSinceReferenceDate], 0.00001, @"");
        XCTAssertEqualWithAccuracy([minValue timeIntervalSinceReferenceDate], [args.min timeIntervalSinceReferenceDate], 0.00001, @"");
        XCTAssertEqualWithAccuracy([maxValue timeIntervalSinceReferenceDate], [args.max timeIntervalSinceReferenceDate], 0.00001, @"");
    };
    
    [Interpreter instance].adapter = adapter;
    [Interpreter instance].complete = ^(BOOL cancelled) {
        
        XCTAssertFalse(cancelled, @"The task was cancelled");
        
        if (!cancelled) {
            
            NSDate *obj = (NSDate *)[[Interpreter instance].variables objectForKey:@"D"];
            NSDate *control = newValue;
            
            XCTAssertEqualWithAccuracy([control timeIntervalSinceReferenceDate], [obj timeIntervalSinceReferenceDate], 0.00001, @"");
        }
        
        [Interpreter instance].adapter = nil;
        [expectation fulfill];
    };
    
    NSString *script = @"SET D = Prompt(date, 'Choose a date', 'Please enter a date', '2015/01/05', '2014/07/06', '2026/04/02')";
    [[Interpreter instance] executeScript:script forReminders:nil];
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     if (error != nil) XCTFail(@"Timeout: %@", error);
                                 }];
}

-(void)test_Set_Prompt_Time_1 {
    // TODO
}

-(void)test_Set_Prompt_Time_2 {
    // TODO
}

-(void)test_Set_Prompt_String_1 {
    // TODO
}

-(void)test_Set_Prompt_String_2 {
    // TODO
}

-(void)test_Set_Prompt_Integer_1 {
    // TODO
}

-(void)test_Set_Prompt_Integer_2 {
    // TODO
}

@end
