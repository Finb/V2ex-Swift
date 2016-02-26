CXSwipeGestureRecognizer
========================

UIGestureRecognizer subclass that takes much of the effort out of managing directional swipes.

    CXSwipeGestureRecognizer *gestureRecognizer = [[CXSwipeGestureRecognizer alloc] init];
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];

✓ Keeps track of both the current direction and the direction the gesture was started in.

    if (gestureRecognizer.initialDirection == CXSwipeGestureDirectionUpwards) {
        if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionDownwards) {
            NSLog(@"Gesture recognizer started swiping upwards and then changed direction");
        }
    }

✓ Delegate protocol methods for `start`, `update`, `cancel`, and `finish`.
    
    - (void)swipeGestureRecognizerDidStart:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        NSLog("Gesture recognizer started");
    }
    
    - (void)swipeGestureRecognizerDidUpdate:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        NSLog("Gesture recognizer updated");
    }
    
    - (void)swipeGestureRecognizerDidCancel:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        NSLog("Gesture recognizer cancelled");
    }
    
    - (void)swipeGestureRecognizerDidFinish:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        NSLog("Gesture recognizer finished");
    }

✓ Convenience methods for `location`, `translation`, `velocity`, and `progress` (note that these work by calling `locationInView:` etc on `self.view.superview`, in case you are using the gesture recognizer to translate the view directly underneath itself).

    NSLog(@"location: %f", gestureRecognizer.location);
    NSLog(@"translation: %f", gestureRecognizer.translation);
    NSLog(@"velocity: %f", gestureRecognizer.velocity);
    NSLog(@"progress: %f", gestureRecognizer.progress);

✓ Delegate method for cancellation.

    /* Cancels the gesture if it has moved less than 32 pixels, or if it is moving in the wrong direction */
    - (BOOL)swipeGestureRecognizerShouldCancel:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        return gestureRecognizer.translation < 32.0f && gestureRecognizer.velocity < 0.0f;
    }

✓ Delegate method for bouncing (returning `YES` causes the `progress` value to be halved, useful when emulating a UIScrollView-style bounce effect).

    /* Bounces the gesture if it has moved backwards past its point of origin */
    - (BOOL)swipeGestureRecognizerShouldBounce:(CXSwipeGestureRecognizer *)gestureRecognizer
    {
        return gestureRecognizer.translation < 0.0f;
    }

### Full API:

CXSwipeGestureRecognizerDelegate <UIGestureRecognizerDelegate>

    - (void)swipeGestureRecognizerDidStart:(CXSwipeGestureRecognizer *)gestureRecognizer;
    - (void)swipeGestureRecognizerDidUpdate:(CXSwipeGestureRecognizer *)gestureRecognizer;
    - (void)swipeGestureRecognizerDidCancel:(CXSwipeGestureRecognizer *)gestureRecognizer;
    - (void)swipeGestureRecognizerDidFinish:(CXSwipeGestureRecognizer *)gestureRecognizer;

    - (BOOL)swipeGestureRecognizerShouldCancel:(CXSwipeGestureRecognizer *)gestureRecognizer;
    - (BOOL)swipeGestureRecognizerShouldBounce:(CXSwipeGestureRecognizer *)gestureRecognizer;

CXSwipeGestureRecognizer : UIPanGestureRecognizer

    @property (unsafe_unretained) id <CXSwipeGestureRecognizerDelegate> delegate;

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
