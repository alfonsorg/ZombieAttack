//
//  MyScene.m
//  2Parcial
//
//  Created by Alfonso Rios Garcia on 28/10/14.
//  Copyright (c) 2014 Alfonso Rios Garcia. All rights reserved.
//

#import "MyScene.h"
#import "GameOver.h"

static const uint32_t projectileCategory =  0x1 << 0;
static const uint32_t zombieCategory     =  0x1 << 1;

@implementation MyScene

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.wallpaper = [SKSpriteNode spriteNodeWithImageNamed:@"street"];
        self.wallpaper.position = CGPointMake(self.wallpaper.size.width/2, self.wallpaper.size.height/2);
        [self addChild:self.wallpaper];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height/2);
        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void) addZombie{
    
    SKSpriteNode * zombie = [SKSpriteNode spriteNodeWithImageNamed:@"monster1"];
    
    zombie.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:zombie.size];
    zombie.physicsBody.dynamic = YES;
    zombie.physicsBody.categoryBitMask = zombieCategory;
    zombie.physicsBody.contactTestBitMask = projectileCategory;
    zombie.physicsBody.collisionBitMask = 0;
    
    int xMinima = zombie.size.width / 2;
    int xMaxima = self.frame.size.width - zombie.size.width / 2;
    int rangoX  = xMaxima - xMinima;
    int x       = (arc4random() % rangoX) + xMinima;
    
    zombie.position = CGPointMake(x, self.frame.size.height + zombie.size.height / 2);
    
    [self addChild:zombie];
    
    int velMinima = 2.0;
    int velMaxima = 4.0;
    int velRango  = velMaxima - velMinima;
    int velocidad = (arc4random() % velRango) + velMinima;
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(x, -zombie.size.height/2) duration:velocidad];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOver = [[GameOver alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOver transition: reveal];
    }];
    
    [zombie runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
}

-(void) updateTimeSinceLastUpdate:(CFTimeInterval) timeSinceLast{
    self.lastSpawnTimeInterval += timeSinceLast;
    if(self.lastSpawnTimeInterval > 1){
        self.lastSpawnTimeInterval = 0;
        [self addZombie];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self runAction:[SKAction playSoundFileNamed:@"arwingPulseLaser.mp3" waitForCompletion:NO]];
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = zombieCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    CGPoint offset = rwSub(location, projectile.position);
    
    if (offset.y <= 0) return;
    
    [self addChild:projectile];
    
    CGPoint direction = rwNormalize(offset);
    CGPoint shootAmount = rwMult(direction, 1000);
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)zombie {
    NSLog(@"Hit");
    [self runAction:[SKAction playSoundFileNamed:@"zombieAttacked.mp3" waitForCompletion:NO]];
    [projectile removeFromParent];
    [zombie removeFromParent];
    
    self.zombiesDestroyed++;
    if (self.zombiesDestroyed >= 10) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOver = [[GameOver alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOver transition: reveal];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & projectileCategory) != 0 && (secondBody.categoryBitMask & zombieCategory) != 0){
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

-(void)update:(NSTimeInterval)currentTime{
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if(timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateTimeSinceLastUpdate:timeSinceLast];
}

@end
