//
//  KeyboardVisibilityHandler.m
//  Runner
//
//  Created by admin on 07/11/2018.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "KeyboardVisibilityPlugin.h"

@import CoreLocation;

@interface FLTKeyboardVisibilityPlugin() <FlutterStreamHandler>

@property (copy, nonatomic) FlutterEventSink flutterEventSink;
@property (assign, nonatomic) BOOL flutterEventListening;
@property (assign, nonatomic) BOOL isVisible;

@end


@implementation FLTKeyboardVisibilityPlugin

+(void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterEventChannel *stream = [FlutterEventChannel eventChannelWithName:@"github.com/adee42/flutter_keyboard_visibility" binaryMessenger:[registrar messenger]];
    
    FLTKeyboardVisibilityPlugin *instance = [[FLTKeyboardVisibilityPlugin alloc] init];
    [stream setStreamHandler:instance];
}

-(instancetype)init {
    self = [super init];
    
    self.isVisible = NO;

    // set up the notifier
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(didHide) name:UIKeyboardDidHideNotification object:nil];

    return self;
}

- (void)didShow
{
    // if state changed and we have a subscriber, let him know
    if (!self.isVisible) {
        self.isVisible = YES;
        if (self.flutterEventListening) {
            self.flutterEventSink([NSNumber numberWithBool:YES]);
        }
    }
}

- (void)didHide
{
    // if state changed and we have a subscriber, let him know
    if (self.isVisible) {
        self.isVisible = NO;
        if (self.flutterEventListening) {
            self.flutterEventSink([NSNumber numberWithBool:NO]);
        }
    }
}

-(FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.flutterEventSink = events;
    self.flutterEventListening = YES;

    // if keyboard is visible at startup, let our subscriber know
    if (self.isVisible) {
        self.flutterEventSink([NSNumber numberWithBool:YES]);
    }
    
    return nil;
}

-(FlutterError*)onCancelWithArguments:(id)arguments {
    self.flutterEventListening = NO;
    return nil;
}

@end
