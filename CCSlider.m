//
//  CCSliderControl.m
//  AmericanTomato
//
//  Created by iroth on 1/5/11.
//  Copyright 2011 iRoth.net. All rights reserved.
//

#import "CCSliderControl.h"


@implementation CCSliderControl

@synthesize value;
@synthesize delegate;

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"init %@", self);

		self.isTouchEnabled = YES;

		value = 0;

		// add the slider background

		CCSprite *bg = [CCSprite spriteWithFile:@"slider_background.png"]; //- TODO: add this to some texture atlas
		[self setContentSize:[bg contentSize]];
		bg.position = CGPointMake([bg contentSize].width / 2, [bg contentSize].height / 2);
		[self addChild:bg];

		// add the slider thumb

		CGSize thumb_size;
		CCSprite *thumb = [CCSprite spriteWithFile:@"slider_thumb.png"]; //- TODO: add this to some texture atlas
		thumb_size = [thumb contentSize];
		minX = thumb_size.width / 2;
		maxX = [self contentSize].width - thumb_size.width / 2;
		thumb.position = CGPointMake(minX, [self contentSize].height / 2);
		[self addChild:thumb];
		
	}
	return self;
}

- (void) setValue:(float) newValue
{
	if (newValue < 0) newValue = 0;
	if (newValue > 1.0) newValue = 1.0;
	value = newValue;
	CCSprite *thumb = (CCSprite *)[[self children] objectAtIndex:1];
	CGPoint pos = thumb.position;
	pos.x = minX + newValue * (maxX - minX);
	thumb.position = pos;
	
}

#pragma mark -
#pragma mark Handle Touch Events

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

-(CGPoint) locationFromTouch:(UITouch *)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
	CGRect bbox = [self boundingBox];
	touchLocation.x -= bbox.origin.x;
	touchLocation.y -= bbox.origin.y;
	return touchLocation;
}

-(bool) isTouchForMe:(CGPoint)touchLocation
{
	CCSprite *bg = (CCSprite *)[[self children] objectAtIndex:0];
	return CGRectContainsPoint([bg boundingBox], touchLocation);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self locationFromTouch:touch];
	bool isTouchHandled = [self isTouchForMe:location];
	if (isTouchHandled) {
		CCSprite *thumb = (CCSprite *)[[self children] objectAtIndex:1];
		thumb.color = ccYELLOW;
		CGPoint pos = thumb.position;
		pos.x = location.x;
		thumb.position = pos;
	}
	return isTouchHandled; // YES for events I handle
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self locationFromTouch:touch];
	if ((location.x < minX) || (location.x > maxX))
		return;

	CCSprite *thumb = (CCSprite *)[[self children] objectAtIndex:1];
	CGPoint pos = thumb.position;
	pos.x = location.x;
	thumb.position = pos;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CCSprite *thumb = (CCSprite *)[[self children] objectAtIndex:1];
	thumb.color = ccWHITE;
	value = (thumb.position.x - minX) / (maxX - minX);
	[delegate valueChanged:value tag:self.tag];
}


@end
