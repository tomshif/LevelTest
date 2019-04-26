//
//  GameScene.swift
//  LevelTest
//
//  Created by Tom Shiflet on 4/1/19.
//  Copyright © 2019 Tom Shiflet. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physTypes
{
    static let None:UInt32 =        0b00000000
    static let Player:UInt32 =      0b00000001
    static let Ground:UInt32 =      0b00000010
    static let Death:UInt32 =       0b00000100
    static let Enemy:UInt32 =       0b00001000
    
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entList=[EntityClass]()
    var level:[Int]=[]
    var lastAlt:Int=0
    let player=SKSpriteNode(imageNamed: "camel")
    var lastJump=NSDate()
    
    var deathBar=SKSpriteNode(imageNamed: "barrier")
    
    var leftPressed:Bool=false
    var rightPressed:Bool=false
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self as SKPhysicsContactDelegate
        
        //player.physicsBody=SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody=SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody!.categoryBitMask=physTypes.Player
        player.physicsBody!.collisionBitMask=physTypes.Ground
        player.physicsBody!.allowsRotation=false
        player.physicsBody!.friction=0.02
        player.physicsBody!.restitution=0.02
        player.position.y=size.height/2
        player.position.x = -size.width/2 + player.size.width/2
        addChild(player)
        player.name="player"
        print("Mass: \(player.physicsBody!.mass)")
        
        print(size.width)
        print(size.height)
        
        deathBar.zRotation=CGFloat.pi/2
        deathBar.position.y = size.height/2-deathBar.size.height
        deathBar.physicsBody=SKPhysicsBody(rectangleOf: deathBar.size)
        deathBar.physicsBody!.categoryBitMask=physTypes.Death
        deathBar.physicsBody!.contactTestBitMask=physTypes.Player
        deathBar.physicsBody!.collisionBitMask=physTypes.None
        deathBar.physicsBody!.isDynamic=false
        deathBar.physicsBody!.affectedByGravity=false
        deathBar.name="deathBar"
        addChild(deathBar)
        
        genLevel()
        
    }
    
    
    func clearEnts()
    {
        if entList.count > 0
        {
            for ent in entList
            {
                ent.die()
                
            }
        } // if we have entities
        
    } // for
    
    func genLevel()
    {
        clearEnts()
        
        for n in self.children
        {
            if n.name != nil
            {
                if n.name!=="grid"
                {
                    n.removeFromParent()
                }
            }
        }
        var alt:Int=5
        var gap=false
        var gapLength=3
        for step in stride(from: 0, to: 16, by: 2)
        {
            let chance=random(min: 0, max: 1)
            if chance > 0.9
            {
                alt -= 1
            }
            else if chance > 0.8
            {
                alt -= 2
            }
            else if chance > 0.7
            {
                alt += 1
            }
            else if chance > 0.6
            {
                alt += 2
            }
            else if chance > 0.5
            {
                alt+=0
            }
            else
            {
                gap=true
                gapLength+=1
            }
            
            
            if alt < 0
            {
                alt=0
            }
            if alt > 6
            {
                alt = 6
            }
            
            if step==0
            {
                alt=lastAlt
                player.position.y = (CGFloat(alt)*64+32-size.height/4) + player.size.height
                player.position.x = -size.width/2 + player.size.width/2
                player.isHidden=false
            }
            
            if !gap || gapLength > 3 || step == 0 || step == 14
            {
                let grid=SKSpriteNode(imageNamed: "grid")
                grid.position=gridOut(x: step, y: alt)
                addChild(grid)
                grid.physicsBody=SKPhysicsBody(rectangleOf: grid.size)
                grid.physicsBody!.affectedByGravity=false
                grid.physicsBody!.categoryBitMask=physTypes.Ground
                grid.physicsBody!.collisionBitMask=physTypes.Player
                grid.physicsBody!.isDynamic=false
                grid.name="grid"
                
                let grid2=SKSpriteNode(imageNamed: "grid")
                grid2.position=gridOut(x:step+1, y: alt)
                grid2.physicsBody=SKPhysicsBody(rectangleOf: grid2.size)
                grid2.physicsBody!.affectedByGravity=false
                grid2.physicsBody!.isDynamic=false
                grid2.physicsBody!.categoryBitMask=physTypes.Ground
                grid2.physicsBody!.collisionBitMask=physTypes.Player
                addChild(grid2)
                grid2.name="grid"
 
                let spawnChance=random(min: 0, max: 1)
                if spawnChance > 0.75
                {
                    let tempEnemy=EntityClass(theScene: self, pos: CGPoint(x: grid.position.x, y: grid.position.y+120))
                    entList.append(tempEnemy)
                }
                
                gapLength=0
            }
            else
            {
                gap=false
                

            }
        } // for
        lastAlt=alt
    }

    func gridOut(x: Int, y: Int) -> CGPoint
    {
        var retPoint=CGPoint()
        retPoint.x=CGFloat(x)*64+32-size.width/2
        retPoint.y=CGFloat(y)*64+32-size.height/4
        return retPoint
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node!.name != nil && secondBody.node!.name != nil
        {
            if firstBody.node!.name!.contains("player") && secondBody.node!.name!.contains("death")
            {
                print("DEATH")
                player.shatter(into: CGSize(width: 2, height: 2), animation: ShatterAnimationType.automatic, showHeatmap: false)
                
            }
        }
        
        
    } // didBegin
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
 
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {

            
        case 2:
            rightPressed=true
        case 0:
            leftPressed=true
        case 15:

            level.removeAll()
            genLevel()
            //player.position.y=size.height/2
            
            
        case 49:
            if -lastJump.timeIntervalSinceNow > 0.5
            {
                player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 400))
                lastJump=NSDate()
            }
            
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            
            
        case 2:
            rightPressed=false
        case 0:
            leftPressed=false
        
            
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func checkEdges()
    {
        if player.position.x > size.width/2-player.size.width/2
        {
            genLevel()

            player.physicsBody!.velocity = .zero
            
        }
    }
    
    func checkKeys()
    {
        if rightPressed
        {
            player.physicsBody!.applyForce(CGVector(dx: 200, dy: 0))
            if player.xScale < 0
            {
                player.xScale *= -1
            }
        }
        if leftPressed
        {
            player.physicsBody!.applyForce(CGVector(dx: -200, dy: 0))
            if player.xScale > 0
            {
                player.xScale *= -1
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        checkKeys()
        checkEdges()
        if entList.count > 0
        {
            for ent in entList
            {
                ent.update()
            }
        } // if we have entities
    } // update
} // class
