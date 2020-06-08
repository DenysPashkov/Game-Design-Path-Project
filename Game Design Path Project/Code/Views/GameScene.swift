//
//  GameScene.swift
//  Game Design Path Project
//
//  Created by admin on 30/03/2020.
//  Copyright © 2020 DenysPashkov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
    private var initialTouch: CGPoint = CGPoint.zero
	private var endTouch : CGPoint = CGPoint.zero
	private var touchStarted: TimeInterval?
	
	private var world : SKNode? = nil
	
	var oldCurrentTime : Double = 0
	var character : MainCharacter!
	
	private let moveJoystick = TLAnalogJoystick(withDiameter: 100)
	
	
	override func didMove(to view: SKView) {

		physicsWorld.contactDelegate = self
		
		backgroundColor = #colorLiteral(red: 0.9051741958, green: 0.8041020036, blue: 0.5297824144, alpha: 1)
		
		world = childNode(withName: "World")
		
		defineTilesetWorld()
		spawnPlayer()
		manageJoystick()
		gestureSetting()
		
		view.isMultipleTouchEnabled = true
	}
	
//	MARK: tileset world
	
	private func defineTilesetWorld(){
		for node in children{
			if node.name == "GroundTiles"{
				if let someTiles : SKTileMapNode = node as? SKTileMapNode{

					giveTileMapPhysicsBody(tileMap: someTiles)
					
					someTiles.removeFromParent()

				}
				break
			}
		}
	}
	
	private func giveTileMapPhysicsBody(tileMap : SKTileMapNode){
		
		let tileSize = tileMap.tileSize
		
		let halfWidth = CGFloat(tileMap.numberOfColumns) / 2 * tileSize.width
		let halfHeight = CGFloat(tileMap.numberOfRows) / 2 * tileSize.height
		
		for col in 0...tileMap.numberOfColumns {
			for row in 0...tileMap.numberOfRows {
				
				if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row){

					let tileArray = tileDefinition.textures
					let tileTexture = tileArray[0]
					let x = CGFloat(col) * tileSize.width - halfWidth + ( tileSize.width / 2)
					let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
					
					let tileNode = SKSpriteNode(texture: tileTexture)
					tileNode.position = CGPoint(x: x, y: y)
					tileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: tileTexture.size().width, height: tileTexture.size().height))
					tileNode.physicsBody?.affectedByGravity = false
					tileNode.physicsBody?.isDynamic = false
					tileNode.physicsBody?.allowsRotation = false
					tileNode.physicsBody?.pinned = true
					tileNode.physicsBody?.contactTestBitMask = UInt32(3)
					tileNode.physicsBody?.categoryBitMask = UInt32(3)
					
					world!.addChild(tileNode)
					
					tileNode.position = CGPoint(x: tileNode.position.x + tileMap.position.x, y: tileNode.position.y + tileMap.position.y)
				}
				
			}
		}
		
	}
	
//	MARK: Recognize Player
	
	private func spawnPlayer() {

		if let characterNode = childNode(withName: "MainCharacter") as? SKSpriteNode{
			character = MainCharacter(cNode: characterNode)
		}

	}
		
//	MARK: Setting Movement
	
	func manageJoystick(){
		
		var image = UIImage(named: "jStick")
		moveJoystick.handleImage = image
		image = UIImage(named: "jSubstrate")
		moveJoystick.baseImage = image
		
		let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: -frame.width / 2, y: frame.height / 2, width: frame.width/2, height: -frame.height))
		moveJoystickHiddenArea.strokeColor = UIColor.black.withAlphaComponent(0)
		moveJoystickHiddenArea.joystick = moveJoystick
		moveJoystick.isMoveable = true
		
		camera!.addChild(moveJoystickHiddenArea)
		
///			move the player
		moveJoystick.on(.move) { [unowned self] joystick in
//			print(joystick.velocity.)
			self.character.xMove(direction: joystick.velocity.x)
			
		}
		
///		when you release the joystick go on idle animation
		moveJoystick.on(.end) { (joystick) in
//			self.character.playerIdleAnimation()
		}
	}
	
//	start Touch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first{
			initialTouch = touch.location(in: self.scene!)
			endTouch = initialTouch
		}
	}
	
//	end Touch
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first?.location(in: self.scene!){
			if touch.x - initialTouch.x > 150 || touch.x - initialTouch.x < -150 {
				character.xAttack(direction: endTouch.x - initialTouch.x)
			} else if touch.y - initialTouch.y > 150 || touch.y - initialTouch.y < -150 {
				character.yAttack(direction: endTouch.y - initialTouch.y)
			}
		}
	}
	
//	MARK: Gesture Implementation
	
	func gestureSetting(){
		
		let shortTapGesture = UITapGestureRecognizer(target: camera?.scene, action: #selector(shortTap(_:)))
		camera?.scene?.view?.addGestureRecognizer(shortTapGesture)
		
		let longTapGesture = UILongPressGestureRecognizer(target: camera?.scene, action: #selector(longPress(_:)))
		longTapGesture.minimumPressDuration = 0.5
		longTapGesture.allowableMovement = 0.1
		camera?.scene?.view?.addGestureRecognizer(longTapGesture)
			
	}
		
//	Short Tap Manage
	
	@objc func shortTap(_ sender: UITapGestureRecognizer) {
		print("short")
		Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
			print("peppe")
		}
		
		if (sender.location(in: camera?.scene?.view).x) > (camera?.scene?.view?.frame.size.width)! / 2 {
			character.doubleJump()
			character.jump()
		}
	}
	
//	Long Tap Manage
	
	@objc func longPress(_ sender: UILongPressGestureRecognizer){
		
		if (sender.location(in: camera?.scene?.view).x) > (camera?.scene?.view?.frame.size.width)! / 2 {
			if character.dash(direction: moveJoystick.velocity.x){
				shakeCamera(layer: camera!, duration: 0.2)
			}
		}
	}
	
//	MARK: Physic contact
	
	func didBegin(_ contact: SKPhysicsContact) {
		
		var firstBody : SKPhysicsBody
		var secondBody : SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			secondBody = contact.bodyA
			firstBody = contact.bodyB
		}
		
///		if collider 1 (player) and collider 3(ground) touch each other you'll be able to jump again using ground touched function
		if firstBody.categoryBitMask == UInt32(1) && secondBody.categoryBitMask == UInt32(3){
			character.groundTouched()
		}
		
	}
	
//	MARK: Utility function
	
	func shakeCamera(layer:SKCameraNode, duration:Float) {

		let amplitudeX:Float = 10;
		let amplitudeY:Float = 6;
		let numberOfShakes = duration / 0.04;
		var actionsArray:[SKAction] = [];
		for _ in 1...Int(numberOfShakes) {
			let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
			let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
			let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
			shakeAction.timingMode = SKActionTimingMode.easeOut;
			actionsArray.append(shakeAction);
			actionsArray.append(shakeAction.reversed());
		}
		
		let actionSeq = SKAction.sequence(actionsArray);
		layer.run(actionSeq);
	}
	
}
