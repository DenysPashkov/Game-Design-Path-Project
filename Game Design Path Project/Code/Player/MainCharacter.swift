//
//  MainCharacter.swift
//  platform 2D movement with dravity
//
//  Created by admin on 23/03/2020.
//  Copyright © 2020 DenysPashkov. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class MainCharacter{
	
	var player : SKSpriteNode
	
//	MARK: Player Characteristic
	
	private let playerSpeed = CGFloat(0.12)
	private let playerColor = UIColor.orange
	
//	MARK: Movement Related
	
	private var isFalling : Bool = false
	private var isDJReady : Bool = false
	private var isDashCD : Bool = false
	private var isLeft = false
	private var isMoving = false
	
//	MARK: Player Animation States
	
	var characterRightIdleFrame : [SKTexture] = []
	var characterLeftIdleFrame : [SKTexture] = []
	
	var characterRightRunFrames : [SKTexture] = []
	var characterLeftRunFrames : [SKTexture] = []
	
//	MARK: Player Init
	
	init(cNode : SKSpriteNode) {
		
		
		
		player = cNode
		player.scene?.scaleMode = .aspectFill
		player.color = playerColor
		
		playerPhysics()
		
//		AddRunAnimation()
//		AddIdleAnimation()

//		playerIdleAnimation()
		
	}
	
//	MARK: Implement Physics
	
	func playerPhysics(){
		
//		let tempPhydicdBoyd = SKPhysicsBody(texture: player.texture!, size: player.size)
		let tempPhydicdBoyd = SKPhysicsBody(rectangleOf: CGSize(width: (player.size.width / 3) - 2, height: player.size.height ))
		
		tempPhydicdBoyd.pinned = false
		tempPhydicdBoyd.affectedByGravity = true
		tempPhydicdBoyd.allowsRotation = false
		tempPhydicdBoyd.isDynamic = true
		tempPhydicdBoyd.categoryBitMask = UInt32(1)
		tempPhydicdBoyd.mass = 0.298474079370499
		
		player.physicsBody = tempPhydicdBoyd
		
	}
	
//	MARK: Movement System
	
	func xMove(direction : CGFloat) {

///			Change animation accordingly to the direction of the character
		if self.isLeft == true && direction > 0{
			isLeft = false
			isMoving = false
		}
		else if self.isLeft == false && direction < 0 {
			isLeft = true
			isMoving = false
		}
		
		if direction != 0 && isMoving == false{

			isMoving = true
//			playerRunAnimation(direction: direction)
			
		}
		
		player.position.x += playerSpeed * direction
		
	}
	
	func jump(){
		if !isFalling {
			isFalling = true
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 110))
		}
	}
	
	func doubleJump() {
		if isDJReady && isFalling{
			isDJReady = false
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
		}
	}
	
	func dash(direction : CGFloat) -> Bool {

		if direction == 0 || isDashCD { return false } else {
			isDashCD = true
			
			player.position.x += 100 * ( direction > 0 ? 1 : -1 )
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) { self.isDashCD = false }
			return true
		}
	}
	
//	MARK: Implement Animation System
	
	func AddIdleAnimation(){
		for i in 1...4{
			
			let textureName = "swordsm_idle_50x30_\(i)"
			
			let tmpImage = UIImage(named: textureName)
			let flipped = flipImageLeftRight(tmpImage!)
			
			var tempTexture = SKTexture(image: tmpImage!)
			tempTexture.filteringMode = .nearest
			characterRightIdleFrame.append(tempTexture)
			
			tempTexture = SKTexture(image: flipped!)
			tempTexture.filteringMode = . nearest
			characterLeftIdleFrame.append(tempTexture)
			
		}
	}
	
	func AddRunAnimation(){
		for i in 1...6{
			
			let textureName = "swordsm_run_50x30_\(i)"
			
			let tempImage = UIImage(named: textureName)
//			let flipped = flipImageLeftRight(tempImage!)
			
//			var tempTexture = SKTexture(image: tempImage!)
//			tempTexture.filteringMode = .nearest
//			characterLeftRunFrames.append(tempTexture)
			
//			tempTexture = SKTexture(image: flipped!)
//			tempTexture.filteringMode = .nearest
//			characterRightRunFrames.append(tempTexture)
			
		}
	}
	
	func playerIdleAnimation(){
		isMoving = false
		player.removeAllActions()
		player.run(SKAction.repeatForever(
			SKAction.animate(with: isLeft ? characterLeftIdleFrame : characterRightIdleFrame,
						 timePerFrame: 0.2,
						 resize: false,
						 restore: true)),
		withKey:"idlePlayer")
	}
	
	func playerRunAnimation(direction : CGFloat){
		player.removeAllActions()
		player.run(SKAction.repeatForever(
			SKAction.animate(with: direction > 0 ? characterLeftRunFrames : characterRightRunFrames,
						 timePerFrame: 0.1,
						 resize: false,
						 restore: true)),
		withKey:"playerRun")
	}
	
//	MARK: Attack
	
	func xAttack(direction : CGFloat){
		
//		let attackSprite = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
//		attackSprite.position = CGPoint(x: player.size.width * (isLeft ? -1 : 1) , y: 0)
//		attackSprite.name = "attack"
//		
//		attackSprite.physicsBody = SKPhysicsBody(rectangleOf: attackSprite.size)
//		
//		attackSprite.physicsBody?.affectedByGravity = false
//		attackSprite.physicsBody?.allowsRotation = false
//		attackSprite.physicsBody?.pinned = true
//		attackSprite.physicsBody?.isDynamic = false
//		
//		attackSprite.physicsBody?.categoryBitMask = UInt32(4)
//		
//		player.addChild(attackSprite)
//		
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//			attackSprite.removeFromParent()
//		}
		
	}
	
	func yAttack(direction : CGFloat){
		
//		let attackSprite = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
//		attackSprite.position = CGPoint(x: player.size.width * (isLeft ? -1 : 1) , y: 0)
//		attackSprite.name = "attack"
//
//		attackSprite.physicsBody = SKPhysicsBody(rectangleOf: attackSprite.size)
//
//		attackSprite.physicsBody?.affectedByGravity = false
//		attackSprite.physicsBody?.allowsRotation = false
//		attackSprite.physicsBody?.pinned = true
//		attackSprite.physicsBody?.isDynamic = false
//
//		attackSprite.physicsBody?.categoryBitMask = UInt32(4)
//
//		player.addChild(attackSprite)
//
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//			attackSprite.removeFromParent()
//		}
		
	}
	
//	MARK: Utility Function
	
	func groundTouched(){
		isFalling = false
		isDJReady = true
	}
	
	func flipImageLeftRight(_ image: UIImage) -> UIImage? {

		UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
		let context = UIGraphicsGetCurrentContext()!
		context.translateBy(x: image.size.width, y: image.size.height)
		context.scaleBy(x: -image.scale, y: -image.scale)

		context.draw(image.cgImage!, in: CGRect(origin:CGPoint.zero, size: image.size))

		let newImage = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()

		return newImage
	}
	
}
