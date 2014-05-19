//
//  CodaLess.m
//  CodaLess
//
//  Created by Theo Weidmann on 18.05.14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

#import "CodaPlugInsController.h"
#import "CodaLess.h"
#import "CodaLessPreferencesWindowController.h"

@implementation CodaLess {
    NSObject<CodaPlugInBundle> *bundle;
    NSUserDefaults *ud;
    CodaLessPreferencesWindowController *pref;
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle>*)plugInBundle {
    self = [super init];
    
    bundle = plugInBundle;
    ud = [NSUserDefaults standardUserDefaults];
    [ud registerDefaults:@{@"cssPath": @"{path}/{basename}.css", @"minify": @NO}];
    
    [aController registerActionWithTitle:@"CodaLess Preferences" underSubmenuWithTitle:nil target:self selector:@selector(showPreferences) representedObject:nil keyEquivalent:nil pluginName:[self name]];
    
    return self;
}

- (NSString *)name {
    return @"CodaLess";
}

- (void)textViewWillSave:(CodaTextView *)textView {
    
    NSString *path = [textView path];
    
    if(![[path pathExtension] isEqualToString:@"less"]) return;
    
    NSString *ipath = [path stringByDeletingLastPathComponent];
    NSString *basename = [[path lastPathComponent] stringByDeletingPathExtension];
    
    NSString *format = [ud stringForKey:@"cssPath"];
    NSString *cssPath = [[format stringByReplacingOccurrencesOfString:@"{path}" withString:ipath] stringByReplacingOccurrencesOfString:@"{basename}" withString:basename];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [bundle.resourcePath stringByAppendingPathComponent:@"less.js/bin/lessc"];
    
    NSMutableArray *lessargs = [NSMutableArray arrayWithObjects:path,cssPath,@"--no-color",nil];
    if([ud boolForKey:@"minify"]){
        [lessargs addObject:@"-x"];
    }
    
    task.arguments = lessargs;
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardError:outputPipe];
    
    [task setTerminationHandler:^(NSTask *task) {
        NSString *s = [[NSString alloc] initWithData: [[outputPipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        if(s.length > 0){
            [[NSAlert alertWithMessageText:@"LESS Compilation" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",s] runModal];
        }
    }];
    [task launch];
}

- (void)showPreferences {
    if(pref == nil){
        pref = [[CodaLessPreferencesWindowController alloc] init];
    }
    [pref showWindow:self];
}

@end
