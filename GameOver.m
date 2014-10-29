//
//  GameOver.m
//  2Parcial
//
//  Created by Alfonso Rios Garcia on 28/10/14.
//  Copyright (c) 2014 Alfonso Rios Garcia. All rights reserved.
//

#import "GameOver.h"
#import "MyScene.h"

@implementation GameOver

-(id)initWithSize:(CGSize)size won:(BOOL)won {
    if (self = [super initWithSize:size]) {
        
        self.wallpaper = [SKSpriteNode spriteNodeWithImageNamed:@"street"];
        self.wallpaper.position = CGPointMake(self.wallpaper.size.width/2, self.wallpaper.size.height/2);
        [self addChild:self.wallpaper];
        
        NSString * message;
        if (won) {
            message = @"You Won! :]";
            [self runAction:[SKAction playSoundFileNamed:@"taDa.mp3" waitForCompletion:NO]];
        } else {
            message = @"You Lose! :[";
            [self runAction:[SKAction playSoundFileNamed:@"torture.mp3" waitForCompletion:NO]];
        }
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor whiteColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:3.0],
                              [SKAction runBlock:^{
             SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
             SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
        
    }
    return self;
}

@end
