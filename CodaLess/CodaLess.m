//
//  CodaLess.m
//  CodaLess
//
//  Created by Theo Weidmann on 18.05.14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

#import "CodaPlugInsController.h"
#import "CodaLess.h"

@implementation CodaLess {
    NSObject<CodaPlugInBundle> *bundle;
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle>*)plugInBundle {
    self = [super init];
    bundle = plugInBundle;
    return self;
}

- (NSString *)name {
    return @"CodaLess";
}

- (void)textViewWillSave:(CodaTextView *)textView {
    
    NSString *path = [textView path];
    
    if(![[path pathExtension] isEqualToString:@"less"]) return;
    
    NSString *cssPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"css"];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [bundle.resourcePath stringByAppendingPathComponent:@"less.js/bin/lessc"];
    task.arguments = @[path,cssPath,@"--no-color"];
    
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

@end
