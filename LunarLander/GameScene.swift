//
//  GameScene.swift
//  LunarLander
//
//  Created by Emin Roblack on 4/7/19.
//  Copyright © 2019 Emin Roblack. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var floor: SKSpriteNode!
    var ship: SKSpriteNode!
    var userTapActive = false
    
    var touchCount: Int = 0
    var touchLocation : CGPoint!
    
    var rotation = 10
    var direction = 0
    var trust = 0
    
    var truster: SKEmitterNode!
    
    
    override func didMove(to view: SKView) {
        
        //physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //physicsWorld.contactDelegate = self
//        scene?.backgroundColor = .lightGray
        
        floor = SKSpriteNode()
        floor.size = CGSize(width: frame.size.width, height: 20)
        floor.color = UIColor.darkGray
        floor.position = CGPoint(x: frame.size.width/2, y: 150)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        //floor.anchorPoint = CGPoint(x: 0, y: 0)
        //floor.physicsBody?.contactTestBitMask = 1
        //floor.zPosition = -1
        addChild(floor)
        
        ship = SKSpriteNode()
        ship.size = CGSize(width: 100, height: 110)
        ship.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        ship.color = UIColor.white
        ship.texture = SKTexture(imageNamed: "testShip")
        ship.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "testShip"), size: ship.size)
//        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        //ship.physicsBody?.linearDamping = 0
        //ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        //ship.physicsBody?.contactTestBitMask = 1
        addChild(ship)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        userTapActive = true
        
//        trust = -20

        touchCount = touches.count
        touchLocation = touches.first?.location(in: self)
        
        truster = SKEmitterNode(fileNamed: "truster")
        truster.name = "trust"
        addChild(truster)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if userTapActive {
            
            trust += 3
            
            switch touchCount {
            case 1:
                if touchLocation.x < self.scene!.frame.width / 2 {
                    direction -= 1
                    rotation += rotation < 10 ? 1 : 0
//                    ship.zRotation = .pi / CGFloat(rotation)
                } else {
                    direction += 1
                    rotation -= rotation > -10 ? 1 : 0
                    
                }
            case 2:
//                direction = 0
                direction += direction > 0 ? -1 : 1
                
                rotation += rotation > 0 ? -1 : 1

                log.ln("DIRECTION: \(direction)")/
            default: direction = 0; rotation = 0
            }
            
            ship.zRotation = .pi * CGFloat(rotation) / 180
            
            ship.physicsBody?.velocity = CGVector(dx: direction, dy: trust)
            truster.position = CGPoint(x: ship.position.x, y: ship.position.y - 35)
        } else {
            trust -= trust < -50 ? 0 : 3
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userTapActive = false
        // Removing all trust nodes from the scene
        scene?.children.filter({ $0.name == "trust" }).forEach({ $0.removeFromParent() })
    }
}
