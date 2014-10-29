//
//  GameOver.h
//  2Parcial
//
//  Created by Alfonso Rios Garcia on 28/10/14.
//  Copyright (c) 2014 Alfonso Rios Garcia. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOver : SKScene
@property (nonatomic) SKSpriteNode * wallpaper;
-(id)initWithSize:(CGSize)size won:(BOOL)won;
@end
