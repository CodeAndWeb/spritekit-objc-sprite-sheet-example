//
//  MyScene.m
//  TexturePacker-SpriteKit
//
//  Created by joachim on 23.09.13.
//  Copyright (c) 2013 CodeAndWeb. All rights reserved.
//

#import "MyScene.h"
#import "sprites.h"


@implementation MyScene

@synthesize sequence;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self initScene];
    }
    return self;
}

-(void)initScene
{
    // load the atlas explicitly, to avoid frame rate drop when starting a new animation
    self.atlas = [SKTextureAtlas atlasNamed:SPRITES_ATLAS_NAME];
    
    // load background image, and set anchor point to the bottom left corner (default: center of sprite)
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:SPRITES_TEX_BACKGROUND];
    background.anchorPoint = CGPointMake(0, 0);
    // add the background image to the SKScene; by default it is added to position 0,0 (bottom left corner) of the scene
    [self addChild: background];

    // in the first animation CapGuy walks from left to right, in the second one he turns from right to left
    SKAction *walk = [SKAction animateWithTextures:SPRITES_ANIM_CAPGUY_WALK timePerFrame:0.033];
    SKAction *turn = [SKAction animateWithTextures:SPRITES_ANIM_CAPGUY_TURN timePerFrame:0.033];

    // as the iPad display has such an enormous width, we have to repeat the animation
    // note: as 'repeat' actions may not be nested, we cannot use [SKAction repeatAction:count:] here,
    //       this would conflict with the [SKAction repeatActionForever:], see below
    SKAction *walkAnim = [SKAction sequence:@[walk, walk, walk, walk, walk, walk]];
    
    // we define two actions to move the sprite from left to right, and back;
    SKAction *moveRight  = [SKAction moveToX:900 duration:walkAnim.duration];
    SKAction *moveLeft   = [SKAction moveToX:100 duration:walkAnim.duration];

    // as we have only an animation with the CapGuy walking from left to right, we use a 'scale' action
    // to get a mirrored animation.
    SKAction *mirrorDirection  = [SKAction scaleXTo:-1 y:1 duration:0.0];
    SKAction *resetDirection   = [SKAction scaleXTo:1  y:1 duration:0.0];
    
    // Action within a group are executed in parallel:
    SKAction *walkAndMoveRight = [SKAction group:@[resetDirection,  walkAnim, moveRight]];
    SKAction *walkAndMoveLeft  = [SKAction group:@[mirrorDirection, walkAnim, moveLeft]];
    
    // now we combine the walk+turn actions into a sequence, and repeat it forever
    self.sequence = [SKAction repeatActionForever:[SKAction sequence:@[walkAndMoveRight, turn, walkAndMoveLeft, turn]]];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // each time the user touches the screen, we create a new sprite, set its position, ...
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:SPRITES_TEX_CAPGUY_WALK_0001];
    sprite.position = CGPointMake(100, rand() % 100 + 200);

    // ... attach the action with the walk animation, and add it to our scene
    [sprite runAction:sequence];
    [self addChild:sprite];
}

@end
