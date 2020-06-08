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
	
	var oldCurrentTime : Double = 0
	var character : MainCharacter!
	
	private let backgroundCustomColor = UIColor.green
	
	private let moveJoystick = TLAnalogJoystick(withDiameter: 100)
	
	override func didMove(to view: SKView) {

		physicsWorld.contactDelegate = self
		
		self.backgroundColor =  backgroundCustomColor
		print("try")
		spawnPlayer()
		manageJoystick()
		gestureSetting()
		
		view.isMultipleTouchEnabled = true
	}
	
//	MARK: Recognize Player
	
	func spawnPlayer() {
		
		if let characterNode = childNode(withName: "MainCharacter") as? SKSpriteNode{
			character = MainCharacter(cNode: characterNode)
			character.player.texture?.filteringMode = .nearest
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
		
		moveJoystick.on(.move) { [unowned self] joystick in

			self.character.xMove(direction: joystick.velocity.x)

		}
	}
//	start Touch
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first{
			initialTouch = touch.location(in: self.scene!)
			endTouch = initialTouch
		}
	}
//	Moving
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		 if let touch = touches.first?.location(in: self.scene!){ endTouch = touch }
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		if endTouch.x - initialTouch.x > 150 || endTouch.x - initialTouch.x < -150 {
			print(endTouch.x - initialTouch.x > 150 ? " X positive" : " X negative")
		} else if endTouch.y - initialTouch.y > 150 || endTouch.y - initialTouch.y < -150 {
			print(endTouch.y - initialTouch.y > 150 ? " Y positive" : " Y negative")
		}
	}
	
//	MARK: Gesture Implementation
	
	func gestureSetting(){
		
			let shortTapGesture = UITapGestureRecognizer(target: camera?.scene, action: #selector(shortTap(_:)))
			camera?.scene?.view?.addGestureRecognizer(shortTapGesture)
			
			let longTapGesture = UILongPressGestureRecognizer(target: camera?.scene, action: #selector(longPress(_:)))
			longTapGesture.minimumPressDuration = 1
			camera?.scene?.view?.addGestureRecognizer(longTapGesture)
			
		}
		
//	Short Tap Manage
	
	@objc func shortTap(_ sender: UITapGestureRecognizer) {
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
