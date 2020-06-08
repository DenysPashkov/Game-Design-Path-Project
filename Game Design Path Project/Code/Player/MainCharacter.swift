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
	
	private var isFalling : Bool
	private var isDJReady : Bool
	var isDashCD : Bool
	
//	MARK: Player Init
	
	init(cNode : SKSpriteNode) {
		
		player = cNode
		player.scene?.scaleMode = .aspectFill
		player.color = playerColor
		isFalling = false
		isDJReady = false
		isDashCD = false
		
	}
	
//	MARK: Movement System
	
	func xMove(direction : CGFloat) {
		player.position.x += playerSpeed * direction
	}
	
	func jump(){
		if !isFalling {
			isFalling = true
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
		}
	}
	
	func doubleJump() {
		if isDJReady && isFalling{
			isDJReady = false
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
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
	
//	MARK: Utility Function
	
	func groundTouched(){
		isFalling = false
		isDJReady = true
	}
	
}
