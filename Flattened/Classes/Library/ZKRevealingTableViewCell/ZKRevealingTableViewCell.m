//
//  ZKRevealingTableViewCell.m
//  ZKRevealingTableViewCell
//
//  Created by Alex Zielenski on 4/29/12.
//  Copyright (c) 2012 Alex Zielenski.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense,  and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ZKRevealingTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ZKRevealingTableViewCell ()

@property (nonatomic, strong) UIPanGestureRecognizer   *_panGesture;
@property (nonatomic, assign) CGFloat _initialTouchPositionX;
@property (nonatomic, assign) CGFloat _initialHorizontalCenter;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection _lastDirection;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection _currentDirection;

- (void)_slideInContentViewFromDirection:(ZKRevealingTableViewCellDirection)direction offsetMultiplier:(CGFloat)multiplier;
- (void)_slideOutContentViewInDirection:(ZKRevealingTableViewCellDirection)direction;

- (void)_pan:(UIPanGestureRecognizer *)panGesture;

- (void)_setRevealing:(BOOL)revealing;

- (CGFloat)_originalCenter;
- (CGFloat)_bounceMultiplier;

- (BOOL)_shouldDragLeft;
- (BOOL)_shouldDragRight;
- (BOOL)_shouldReveal;

@end

@implementation ZKRevealingTableViewCell

#pragma mark - Private Properties

@synthesize _panGesture;
@synthesize _initialTouchPositionX;
@synthesize _initialHorizontalCenter;
@synthesize _lastDirection;
@synthesize _currentDirection;

#pragma mark - Public Properties

@dynamic revealing;
@synthesize direction    = _direction;
@synthesize delegate     = _delegate;
@synthesize shouldBounce = _shouldBounce;
@synthesize backView     = _backView;

#pragma mark - Lifecycle

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
//    self = [super awakeAfterUsingCoder:aDecoder];
    if (self) {
        self.direction = ZKRevealingTableViewCellDirectionBoth;
		self.shouldBounce = YES;
		
		self._panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
		self._panGesture.delegate = self;
		
		[self addGestureRecognizer:self._panGesture];
		
		self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table-row-bkg.png"]];
		
		UIView *backgroundView         = [[UIView alloc] initWithFrame:self.contentView.frame];
		backgroundView.backgroundColor = [UIColor greenColor];
		self.backView                  = backgroundView;
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self addSubview:self.backView];
	[self addSubview:self.contentView];
    
    UIView *alphaView = [self.contentView viewWithTag:123];
    if (!self.contentView.frame.origin.x && alphaView) {
        alphaView.alpha = 0;
    }
}

#pragma mark - Accessors
#import <objc/runtime.h>

static char BOOLRevealing;

- (BOOL)isRevealing
{
	return [(NSNumber *)objc_getAssociatedObject(self, &BOOLRevealing) boolValue];
}

- (void)setRevealing:(BOOL)revealing
{
	// Don't change the value if its already that value.
	// Reveal unless the delegate says no
	if (revealing == self.revealing || 
		(revealing && self._shouldReveal))
		return;
	
	[self _setRevealing:revealing];
	
	if (self.isRevealing)
		[self _slideOutContentViewInDirection:(self.isRevealing) ? self._currentDirection : self._lastDirection];
	else
		[self _slideInContentViewFromDirection:(self.isRevealing) ? self._currentDirection : self._lastDirection offsetMultiplier:self._bounceMultiplier];
}

- (void)_setRevealing:(BOOL)revealing
{
	[self willChangeValueForKey:@"isRevealing"];
	objc_setAssociatedObject(self, &BOOLRevealing, [NSNumber numberWithBool:revealing], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"isRevealing"];
	
	if (self.isRevealing && [self.delegate respondsToSelector:@selector(cellDidReveal:)])
		[self.delegate cellDidReveal:self];
}

- (BOOL)_shouldReveal
{
	// Conditions are checked in order
	return (![self.delegate respondsToSelector:@selector(cellShouldReveal:)] || [self.delegate cellShouldReveal:self]);
}

#pragma mark - Handing Touch

- (void)_pan:(UIPanGestureRecognizer *)recognizer
{
    [self setSelected:NO animated:NO];
	CGPoint translation           = [recognizer translationInView:self];
	CGPoint currentTouchPoint     = [recognizer locationInView:self];
	CGPoint velocity              = [recognizer velocityInView:self];
	
	CGFloat originalCenter        = self._originalCenter;
	CGFloat currentTouchPositionX = currentTouchPoint.x;
	CGFloat panAmount             = self._initialTouchPositionX - currentTouchPositionX;
	CGFloat newCenterPosition     = self._initialHorizontalCenter - panAmount;
	CGFloat centerX               = self.contentView.center.x;
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		
		// Set a baseline for the panning
		self._initialTouchPositionX = currentTouchPositionX;
		self._initialHorizontalCenter = self.contentView.center.x;
		
		if ([self.delegate respondsToSelector:@selector(cellDidBeginPan:)])
			[self.delegate cellDidBeginPan:self];
		
        
        UIView *alphaView = [self.contentView viewWithTag:123];
        if (!alphaView) {
            alphaView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.contentView.bounds.size.width-5, self.contentView.bounds.size.height)];
            alphaView.backgroundColor = [UIColor whiteColor];
            alphaView.alpha = 0;
            alphaView.tag = 123;
            [self.contentView addSubview:alphaView];
        }
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		
		// If the pan amount is negative, then the last direction is left, and vice versa.
		if (newCenterPosition - centerX < 0)
			self._lastDirection = ZKRevealingTableViewCellDirectionLeft;
		else
			self._lastDirection = ZKRevealingTableViewCellDirectionRight;
		
		// Don't let you drag past a certain point depending on direction
		if ((newCenterPosition < originalCenter && !self._shouldDragLeft) || (newCenterPosition > originalCenter && !self._shouldDragRight))
			newCenterPosition = originalCenter;
		
		// Let's not go waaay out of bounds
		if (newCenterPosition > _backView.bounds.size.width + originalCenter)
			newCenterPosition = _backView.bounds.size.width + originalCenter;
		
		else if (newCenterPosition < -originalCenter)
			newCenterPosition = -originalCenter;
		
		CGPoint center = self.contentView.center;
		center.x = newCenterPosition;
        
        UIView *alphaView = [self.contentView viewWithTag:123];
        CGFloat alpha = (newCenterPosition - originalCenter) / _backView.bounds.size.width;
        alpha = alpha < 0.5 ? alpha : 0.5;
        alphaView.alpha = alpha;
		
		self.contentView.layer.position = center;
		
	} else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
				
		// Swiping left, velocity is below 0.
		// Swiping right, it is above 0
		// If the velocity is above the width in points per second at any point in the pan, push it to the acceptable side
		// Otherwise, if we are 60 points in, push to the other side
		// If we are < 60 points in, bounce back
		
#define kMinimumVelocity _backView.frame.size.width
#define kMinimumPan      60.0
		
		CGFloat velocityX = velocity.x;
		
		BOOL push = (velocityX < -kMinimumVelocity);
		push |= (velocityX > kMinimumVelocity);
		push |= ((self._lastDirection == ZKRevealingTableViewCellDirectionLeft && translation.x < -kMinimumPan) || (self._lastDirection == ZKRevealingTableViewCellDirectionRight && translation.x > kMinimumPan));
		push &= self._shouldReveal;
		push &= ((self._lastDirection == ZKRevealingTableViewCellDirectionRight && self._shouldDragRight) || (self._lastDirection == ZKRevealingTableViewCellDirectionLeft && self._shouldDragLeft)); 
		
		if (velocityX > 0 && self._lastDirection == ZKRevealingTableViewCellDirectionLeft)
			push = NO;
		
		else if (velocityX < 0 && self._lastDirection == ZKRevealingTableViewCellDirectionRight)
			push = NO;
		
		if (push && !self.isRevealing) {
			
			[self _slideOutContentViewInDirection:self._lastDirection];
			[self _setRevealing:YES];
			
			self._currentDirection = self._lastDirection;
			
		} else if (self.isRevealing && translation.x != 0) {
			CGFloat multiplier = self._bounceMultiplier;
			if (!self.isRevealing)
				multiplier *= -1.0;
				
			[self _slideInContentViewFromDirection:self._currentDirection offsetMultiplier:multiplier];
			[self _setRevealing:NO];
			
		} else if (translation.x != 0) {
			// Figure out which side we've dragged on.
			ZKRevealingTableViewCellDirection finalDir = ZKRevealingTableViewCellDirectionRight;
			if (translation.x < 0)
				finalDir = ZKRevealingTableViewCellDirectionLeft;
		
			[self _slideInContentViewFromDirection:finalDir offsetMultiplier:-1.0 * self._bounceMultiplier];
			[self _setRevealing:NO];
		}
	}
}

- (BOOL)_shouldDragLeft
{
	return (self.direction == ZKRevealingTableViewCellDirectionBoth || self.direction == ZKRevealingTableViewCellDirectionLeft);
}

- (BOOL)_shouldDragRight
{
	return (self.direction == ZKRevealingTableViewCellDirectionBoth || self.direction == ZKRevealingTableViewCellDirectionRight);
}

- (CGFloat)_originalCenter
{
	return ceil(self.contentView.bounds.size.width / 2);
}

- (CGFloat)_bounceMultiplier
{
	return self.shouldBounce ? MIN(ABS(self._originalCenter - self.contentView.center.x) / kMinimumPan, 1.0) : 0.0;
}

#pragma mark - Sliding
#define kBOUNCE_DISTANCE 20.0

- (void)_slideInContentViewFromDirection:(ZKRevealingTableViewCellDirection)direction offsetMultiplier:(CGFloat)multiplier
{
	CGFloat bounceDistance;
	
	if (self.contentView.center.x == self._originalCenter)
		return;
	
	switch (direction) {
		case ZKRevealingTableViewCellDirectionRight:
			bounceDistance = kBOUNCE_DISTANCE * multiplier;
			break;
		case ZKRevealingTableViewCellDirectionLeft:
			bounceDistance = -kBOUNCE_DISTANCE * multiplier;
			break;
		default:
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled gesture direction" userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:direction] forKey:@"direction"]];
			break;
	}
	
	
	[UIView animateWithDuration:0.1
						  delay:0 
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
					 animations:^{
                         self.contentView.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.center.y);
                         
                         UIView *alphaView = [self.contentView viewWithTag:123];
                         alphaView.alpha = 0;
                     }
					 completion:^(BOOL f) {
                         UIView *alphaView = [self.contentView viewWithTag:123];
                         [alphaView removeFromSuperview];
						 						 
						 [UIView animateWithDuration:0.1 delay:0 
											 options:UIViewAnimationCurveLinear
										  animations:^{ self.contentView.frame = CGRectOffset(self.contentView.frame, bounceDistance, 0); } 
										  completion:^(BOOL f) {                     
											  
												  [UIView animateWithDuration:0.1 delay:0 
																	  options:UIViewAnimationCurveLinear
																   animations:^{ self.contentView.frame = CGRectOffset(self.contentView.frame, -bounceDistance, 0); } 
																   completion:NULL];
										  }
						  ]; 
					 }];
}

- (void)_slideOutContentViewInDirection:(ZKRevealingTableViewCellDirection)direction;
{
	int x;
	
	switch (direction) {
		case ZKRevealingTableViewCellDirectionLeft:
			x = - self._originalCenter;
			break;
		case ZKRevealingTableViewCellDirectionRight:
			x = _backView.frame.size.width + self._originalCenter;
			break;
		default:
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled gesture direction" userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:direction] forKey:@"direction"]];
			break;
	}
	
    UIView *alphaView = [self.contentView viewWithTag:123];
    if (!alphaView) {
        alphaView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.contentView.bounds.size.width-5, self.contentView.bounds.size.height)];
        alphaView.backgroundColor = [UIColor whiteColor];
        alphaView.alpha = 0;
        alphaView.tag = 123;
        [self.contentView addSubview:alphaView];
    }
    
	[UIView animateWithDuration:0.2
						  delay:0 
						options:UIViewAnimationOptionCurveEaseOut 
					 animations:^{
                         self.contentView.center = CGPointMake(ceil(x), self.contentView.center.y);
                         UIView *alphaView = [self.contentView viewWithTag:123];
                         alphaView.alpha = 0.5;
                     }
					 completion:NULL];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == self._panGesture) {
		UIScrollView *superview = (UIScrollView *)self.superview;
		CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
		
		// Make sure it is scrolling horizontally
		return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
	}
	return NO;
}

@end
