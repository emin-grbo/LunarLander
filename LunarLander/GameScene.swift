//
//  GameScene.swift
//  LunarLander
//
//  Created by Emin Roblack on 4/7/19.
//  Copyright © 2019 Emin Roblack. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let landerSprite = "lander"
    let mainStairsSprite = "floorMain"
    let skySprite = "sky"
    let rightStairsSprite = "rightStairs"
    
    let map = SKNode()
    
    var floor: SKSpriteNode!
    var ship: SKSpriteNode!
    var rightStairs: SKSpriteNode!
    var trustFire: SKSpriteNode!
    var userTapActive = false
    
    var touchCount: Int = 0
    var touchLocation : CGPoint!
    
    var isTouching: Bool = true
    
    var rotation = 10.0
    var direction = 0
    var trust = 0 { didSet {
        if trust == 0 {
            trust = -5
        }
        }}
    
    var trusterLeft: SKEmitterNode!
    var trusterRight: SKEmitterNode!
    
    override func didMove(to view: SKView) {

        physicsWorld.contactDelegate = self
        
        let tileSet = SKTileSet(named: "LunarLander")!
        let tileSize = CGSize(width: 128, height: 128)
        let floorTileSize = CGSize(width: 160, height: 128)
        let columns = 128
        let rows = 128
        
        let screenWidth = Int(frame.size.width)
        let halfScreenW = screenWidth/2
        let screenHeight = Int(frame.size.height)
        let halfScreenH = screenHeight/2
        
        let floorTiles = tileSet.tileGroups.first { $0.name == mainStairsSprite}
        let skyTiles = tileSet.tileGroups.first { $0.name == skySprite}
        
        rightStairs = SKSpriteNode()
        rightStairs.size = CGSize(width: 144, height: 40)
        rightStairs.position = CGPoint(x: screenWidth - 142, y: halfScreenH)
        rightStairs.texture = SKTexture(imageNamed: rightStairsSprite)
        rightStairs.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: rightStairsSprite), size: rightStairs.size)
        rightStairs.physicsBody?.isDynamic = false
        rightStairs.physicsBody?.contactTestBitMask = 1
        addChild(rightStairs)
        
        ship = SKSpriteNode()
        ship.size = CGSize(width: 102, height: 72)
        ship.position = CGPoint(x: halfScreenW, y: 200)
        ship.color = UIColor.white
        ship.texture = SKTexture(imageNamed: landerSprite)
        ship.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: landerSprite), size: ship.size)
        ship.physicsBody?.categoryBitMask = 1
        addChild(ship)
        
        // MARK: Particle Test
        // ------------------------------------------------------------------------------------
//        let particleLayer = CAEmitterLayer()
//        particleLayer.frame = CGRect(x: 200, y: 200, width: 20, height: 20)
//        view.layer.addSublayer(particleLayer)
//        view.layer.masksToBounds = false
//        particleLayer.backgroundColor = UIColor.white.cgColor
//        particleLayer.emitterMode = .surface
//        particleLayer.renderMode = .additive
//        particleLayer.emitterShape = .rectangle
//
//        let image = UIImage(named: "exhaust1")?.cgImage
//        let cell = CAEmitterCell()
//        cell.scale = 1
//        cell.lifetime = 0.5
//        cell.birthRate = 5
//        cell.contents = image
//
//        let image2 = UIImage(named: "exhaust2")?.cgImage
//        let cell2 = CAEmitterCell()
//        cell2.scale = 1
//        cell2.lifetime = 0.2
//        cell2.birthRate = 5
//        cell2.contents = image2
//        cell.velocity = 50
//        cell.emissionLatitude = 20
//        cell.emissionLongitude = 10
//        cell.xAcceleration = 10
//        particleLayer.emitterCells = [cell, cell2]
        // ------------------------------------------------------------------------------------
        
        
        // MARK: Adding a tileSet ----------------------------------------------------------------
        addChild(map)
        map.xScale = 1
        map.yScale = 1
        
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: screenHeight/columns, rows: screenHeight/rows + 1, tileSize: tileSize)
        bottomLayer.anchorPoint = CGPoint(x: 0, y: 0)
        bottomLayer.position = CGPoint(x: 0, y: 0)
        bottomLayer.enableAutomapping = true
        bottomLayer.fill(with: skyTiles)
        map.addChild(bottomLayer)
        // ------------------------------------------------------------------------------------

        let floorLayer = SKTileMapNode(tileSet: tileSet, columns: 1, rows: 1, tileSize: floorTileSize)
        floorLayer.enableAutomapping = true
        floorLayer.position = CGPoint(x: halfScreenW, y: 64)
        floorLayer.physicsBody = SKPhysicsBody(rectangleOf: floorLayer.mapSize)
        floorLayer.physicsBody?.isDynamic = false
        floorLayer.physicsBody?.contactTestBitMask = 1
        floorLayer.fill(with: floorTiles)
        map.addChild(floorLayer)

        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        userTapActive = true
        
        touchCount = touches.count
        touchLocation = touches.first?.location(in: self)
        
        trusterLeft = SKEmitterNode(fileNamed: "truster")
        trusterRight = SKEmitterNode(fileNamed: "truster")
        trusterLeft.position = CGPoint(x: -20, y: -30)
        trusterRight.position = CGPoint(x: 16, y: -30)
        trusterLeft.name = "trust"
        trusterRight.name = "trust"
        ship.addChild(trusterLeft)
        ship.addChild(trusterRight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if userTapActive {
            
            trust += 3
            
            switch touchCount {
            case 1:
                if touchLocation.x < self.scene!.frame.width / 2 {
                    direction -= 1
                    rotation += rotation < 10 ? 1 : 0
                    trusterLeft.alpha = 0.2
                } else {
                    direction += 1
                    rotation -= rotation > -10 ? 1 : 0
                    trusterRight.alpha = 0.2
                }
            case 2:
                direction += direction > 0 ? -1 : 1
                rotation += rotation > 0 ? -1 : 1
            default: direction = 0; rotation = 0
            }
            
            ship.zRotation = .pi * CGFloat(rotation) / 180
            ship.physicsBody?.velocity = CGVector(dx: direction, dy: trust)
            
        } else {
            // Disabling rotation in case of contact
            ship.physicsBody?.angularVelocity = 0
            
            // Lowering speed as user it not touching the screen
            trust -= trust > -50 ? 5 : 0
            
            while rotation != 0 && isTouching {
                if rotation > 0 { rotation -= 1 } else { rotation += 1 }
                direction = 0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userTapActive = false
        // Removing all trust nodes from the scene
        ship.children.filter({ $0.name == "trust" }).forEach({ $0.removeFromParent() })
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        log.ln("TEST")/
//    }
//

    func didBegin(_ contact: SKPhysicsContact) {
        isTouching = true
//        log.ln("Begin contact")/
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        isTouching = false
//        log.ln("End contact")/
    }
}
