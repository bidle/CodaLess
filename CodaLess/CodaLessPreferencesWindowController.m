//
//  CodaLessPreferencesWindowController.m
//  CodaLess
//
//  Created by Theo Weidmann on 19.05.14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

#import "CodaLessPreferencesWindowController.h"

@interface CodaLessPreferencesWindowController ()

@end

@implementation CodaLessPreferencesWindowController {
    NSUserDefaults *ud;
}

- (instancetype)init {
    self = [super initWithWindowNibName:@"CodaLessPreferencesWindowController" owner:self];
    if (self) {
        ud = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.pathField setStringValue:[ud stringForKey:@"cssPath"]];
    [self.minifyCheckBox setState:([ud boolForKey:@"minify"]) ? 1 : 0];
}

- (IBAction)minifyChanged:(id)sender {
    [ud setBool:(self.minifyCheckBox.state == 1) ? YES : NO forKey:@"minify"];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    [ud setObject:[self.pathField stringValue] forKey:@"cssPath"];
}
@end
