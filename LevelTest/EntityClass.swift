//
//  EntityClass.swift
//  LevelTest
//
//  Created by Tom Shiflet on 4/23/19.
//  Copyright © 2019 Tom Shiflet. All rights reserved.
//

import Foundation
import SpriteKit

class EntityClass
{
    var sprite=SKSpriteNode(imageNamed: "ent")
    var scene:SKScene?
    var moveSpeed:CGFloat=65
    var lastTurnCheck=NSDate()
    
    init()
    {
        
    }
    
    init(theScene: SKScene, pos:CGPoint)
    {
        scene=theScene
        sprite.position=pos
        sprite.setScale(0.5)
        sprite.physicsBody=SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.categoryBitMask=physTypes.Enemy
        sprite.physicsBody!.collisionBitMask=physTypes.Ground | physTypes.Player
        sprite.physicsBody!.affectedByGravity=true
        sprite.physicsBody!.isDynamic=true
        sprite.physicsBody!.allowsRotation=false
        sprite.physicsBody!.friction=0.1
        scene?.addChild(sprite)
        let moveDir=random(min: 0, max: 1)
        if moveDir > 0.5
        {
            moveSpeed *= -1
        }
    }
    
    func die()
    {
        sprite.removeFromParent()
    }
    
    
    
    func update()
    {
        
      

        // check to see if we need to turn around
        if -lastTurnCheck.timeIntervalSinceNow > 0.01
        {
            var turn:Bool=false
            var onBlock:Bool=false
            for this in sprite.physicsBody!.allContactedBodies()
            {
                if this.node!.name != nil
                {
                    if this.node!.name!.contains("grid")
                    {
                        onBlock=true
                    }
                }
            }
            if !onBlock
            {
                turn=true
            }

            
            if turn
            {
                moveSpeed *= -1
                turn=false
            } // if it's time to turn around
            
            lastTurnCheck=NSDate()
        } // if it's time to check turn
        if sprite.physicsBody!.velocity.dx < 150 && sprite.physicsBody!.velocity.dx > -50
        {
            sprite.physicsBody!.applyForce(CGVector(dx: moveSpeed, dy: 1))
        }
        print(moveSpeed)
    }
    
} // class Entity Class
