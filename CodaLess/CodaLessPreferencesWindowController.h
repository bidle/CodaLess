//
//  CodaLessPreferencesWindowController.h
//  CodaLess
//
//  Created by Theo Weidmann on 19.05.14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CodaLessPreferencesWindowController : NSWindowController<NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *pathField;
@property (weak) IBOutlet NSButton *minifyCheckBox;
- (IBAction)minifyChanged:(id)sender;

@end
