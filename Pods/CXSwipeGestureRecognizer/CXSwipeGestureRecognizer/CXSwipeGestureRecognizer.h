//
//  CXSwipeGestureRecognizer.h
//  CALX
//
//  Created by Daniel Clelland on 24/06/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, CXSwipeGestureDirection) {
    CXSwipeGestureDirectionNone = 0,
    CXSwipeGestureDirectionDownwards = 1 << 0,
    CXSwipeGestureDirectionLeftwards = 1 << 1,
    CXSwipeGestureDirectionUpwards = 1 << 2,
    CXSwipeGestureDirectionRightwards = 1 << 3,
    CXSwipeGestureDirectionVertical = CXSwipeGestureDirectionDownwards | CXSwipeGestureDirectionUpwards,
    CXSwipeGestureDirectionHorizontal = CXSwipeGestureDirectionLeftwards | CXSwipeGestureDirectionRightwards,
    CXSwipeGestureDirectionAll = CXSwipeGestureDirectionVertical | CXSwipeGestureDirectionHorizontal
};

@class CXSwipeGestureRecognizer;

@protocol CXSwipeGestureRecognizerDelegate <UIGestureRecognizerDelegate>

@optional

- (void)swipeGestureRecognizerDidStart:(CXSwipeGestureRecognizer *)gestureRecognizer;
- (void)swipeGestureRecognizerDidUpdate:(CXSwipeGestureRecognizer *)gestureRecognizer;
- (void)swipeGestureRecognizerDidCancel:(CXSwipeGestureRecognizer *)gestureRecognizer;
- (void)swipeGestureRecognizerDidFinish:(CXSwipeGestureRecognizer *)gestureRecognizer;

- (BOOL)swipeGestureRecognizerShouldCancel:(CXSwipeGestureRecognizer *)gestureRecognizer;
- (BOOL)swipeGestureRecognizerShouldBounce:(CXSwipeGestureRecognizer *)gestureRecognizer;

@end

@interface CXSwipeGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) id <CXSwipeGestureRecognizerDelegate> delegate;

- (CXSwipeGestureDirection)initialDirection;
- (CXSwipeGestureDirection)currentDirection;

- (CGFloat)location;
- (CGFloat)locationInDirection:(CXSwipeGestureDirection)direction;
- (CGFloat)locationInDirection:(CXSwipeGestureDirection)direction inView:(UIView *)view;

- (CGFloat)translation;
- (CGFloat)translationInDirection:(CXSwipeGestureDirection)direction;
- (CGFloat)translationInDirection:(CXSwipeGestureDirection)direction inView:(UIView *)view;

- (CGFloat)velocity;
- (CGFloat)velocityInDirection:(CXSwipeGestureDirection)direction;
- (CGFloat)velocityInDirection:(CXSwipeGestureDirection)direction inView:(UIView *)view;

- (CGFloat)progress;
- (CGFloat)progressInDirection:(CXSwipeGestureDirection)direction;
- (CGFloat)progressInDirection:(CXSwipeGestureDirection)direction inView:(UIView *)view;

@end
