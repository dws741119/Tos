import SpriteKit

class GameScene: SKScene {

	var currentBead :beadSpriteNode! = beadSpriteNode()
	var shadowBead :beadSpriteNode! = beadSpriteNode()
	var beadBoard :SKSpriteNode! = SKSpriteNode()
    
    var runActionBeadCount = 0
	var lockTouch = false

    override func didMoveToView(view: SKView) {
        let mainSceneTexture = SKTexture(imageNamed:"mainScene")
        let mainScene = SKSpriteNode(texture:mainSceneTexture)
        mainScene.anchorPoint = CGPointZero
        mainScene.position = CGPoint(x: 0.0, y:0.0)
        self.addChild(mainScene)
        
        let boadrTexture = SKTexture(imageNamed:"chessbroad")
        beadBoard = SKSpriteNode(texture:boadrTexture)
        beadBoard.anchorPoint = CGPointZero
        beadBoard.position = CGPoint(x:0,y:0)
        self.addChild(beadBoard)
        
        shadowBead = beadSpriteNode.createBead(column: 0, row: 0)
        shadowBead.anchorPoint = CGPoint(x: 0.4, y: 0.3)
        shadowBead.hidden = true
        self.addChild(shadowBead)

        for col in 0..<6 {
            for row in 0..<5 {
                let bead = beadSpriteNode.createBead(column: col, row: row)
                beadBoard.addChild(bead)
                bead.runAction(SKAction.moveTo(bead.finalPosition, duration: 0.25))
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

		if lockTouch {
			return
		}

		let location = touches.allObjects[0].locationInNode(beadBoard)
        var bead = beadBoard.nodeAtPoint(location)
        if (bead.isKindOfClass(beadSpriteNode)) {

            currentBead = beadBoard.nodeAtPoint(location) as beadSpriteNode!
            currentBead.alpha = 0.2
            
            shadowBead.texture = currentBead.texture
            shadowBead.position = currentBead.position
            shadowBead.alpha = 0.5
            shadowBead.hidden = false
        }
	}

	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

		if lockTouch {
			return
		}

        var location = touches.allObjects[0].locationInNode(beadBoard)
        
        if currentBead == nil {
            return
        }
        shadowBead.position = location
        
        if location.y > beadBoard.size.height {
            location.y = beadBoard.size.height - 10
        }
        
        var obj = beadBoard.nodeAtPoint(location)

        if obj.isKindOfClass(beadSpriteNode) && !obj.isEqual(currentBead) {

			let bead = obj as beadSpriteNode!

			let animationBead = SKSpriteNode(texture:bead.texture)
			animationBead.position = bead.position;
			self.addChild(animationBead)

			let tempPosition = bead.position;
			bead.hidden = true
			bead.position = currentBead.position;

			animationBead.runAction(SKAction.moveTo(currentBead.position, duration: 0.09), completion:{() in
				bead.hidden = false
				animationBead.removeFromParent()
				})
			
            currentBead.position = tempPosition;
        }
    }

	override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {

		if lockTouch {
			return
		}

        if (currentBead) {
            shadowBead.hidden = true
            currentBead.alpha = 1
            currentBead = nil
            self.calculateCombo()
        }
	}

	override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {

		if lockTouch {
			return
		}

        if (currentBead) {
            shadowBead.hidden = true
            currentBead.alpha = 1
            currentBead = nil
            self.calculateCombo()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
    }
    
	func beadInLacation(#column:Int, row:Int)->beadSpriteNode? {
        var potision = CGPoint(x: column * 53 + 28, y: row * 53 + 28)
        var obj = beadBoard.nodeAtPoint(potision)
        return obj.isKindOfClass(beadSpriteNode) ? obj as beadSpriteNode! : nil;
	}

	func fillBead () {

		lockTouch = true

		var needLockTouch = false
		for col in 0..<6 {
            
            var count = 0
            var needMove = false
            var tagetRow = 0
            
            var beads:[AnyObject] = []
            
            for row in 0..<5 {
                let bead = self.beadInLacation(column:col, row:row)

                if bead == nil && !needMove {
                    needMove = true
                    tagetRow = row
                }
                else if bead != nil {
                    count++
                    if needMove {
                        bead!.finalPosition(column: col, row: tagetRow)
                        self.runActionBeadCount++
                        beads.append(bead!)
                        tagetRow++
                    }
                }
            }
            
            if count != 5 {
                var row = 0
                for i in count..<5 {
                    let bead = beadSpriteNode.createBead(column: col, row: i)
                    bead.position = CGPoint(x: col * 53 + 28, y: row * 53 + 264)
                    self.runActionBeadCount++
                    beadBoard.addChild(bead)
                    beads.append(bead)
                    row++
                }
            }

            for obj : AnyObject in beads {
				needLockTouch = true
                let bead:beadSpriteNode = obj as beadSpriteNode
                bead.runAction(SKAction.moveTo(bead.finalPosition, duration:0.2), completion:{() in
                    self.runActionBeadCount--
                    if self.runActionBeadCount == 0 {
                        self.calculateCombo()
                    }
                    })
            }
		}

		lockTouch = needLockTouch
	}

    func calculateCombo () {

		lockTouch = true

		var tag = 1

		for column in 0..<6 {
			for row in 0..<5 {
				var bead:beadSpriteNode? = beadInLacation(column:column, row:row)

				var currentTag = tag
				for i in [[1,0],[-1,0],[0,1],[0,-1]] {
					var tmpBead:beadSpriteNode? = beadInLacation(column:column + i[0], row:row + i[1])
					if tmpBead != nil  && tmpBead!.type == bead!.type && tmpBead!.tag != 0 {
						currentTag = tmpBead!.tag
					}
				}

				findCombo(column: column, row: row, tag: currentTag)

				var downBead:beadSpriteNode? = beadInLacation(column:column, row:row + 1)
				if downBead != nil {
					if bead!.type == downBead!.type {
						findCombo(column: column, row: row + 1, tag: currentTag)
					}
				}

				var leftBead:beadSpriteNode? = beadInLacation(column:column + 1, row:row)
				if leftBead != nil {
					if bead!.type == leftBead!.type {
						findCombo(column: column + 1, row: row, tag: currentTag)
					}
				}

				if bead!.tag == tag {
					tag++
				}
			}
		}

		tag = 0
		for row in [4,3,2,1,0] {
			for column in 0..<6 {
				var bead:beadSpriteNode? = beadInLacation(column:column, row:row)
				tag = max(bead!.tag,tag)
			}
		}

		lockTouch = false
		removeCombo(tag)
    }

	func findCombo (#column:Int,row:Int,tag:Int) {

		if column < 0 || row < 0 {
			return
		}
		if var bead:beadSpriteNode? = beadInLacation(column:column, row:row) {
			for i in [[1,2],[-1,-2],[1,-1]] {
				var bead1:beadSpriteNode? = beadInLacation(column:column + i[0] , row:row)
				var bead2:beadSpriteNode? = beadInLacation(column:column + i[1] , row:row)
				if checkComboAndAddTag(bead: bead, bead2: bead1, bead3: bead2, tag:tag) {
					findCombo(column: column + i[0], row: row, tag: tag)
					findCombo(column: column + i[1], row: row, tag: tag)
				}

				var bead3:beadSpriteNode? = beadInLacation(column:column , row:row + i[0])
				var bead4:beadSpriteNode? = beadInLacation(column:column , row:row + i[1])
				if checkComboAndAddTag(bead: bead, bead2: bead3, bead3: bead4, tag:tag) {
					findCombo(column: column , row: row + i[0], tag: tag)
					findCombo(column: column , row: row + i[1], tag: tag)
				}
			}
		}
	}

	func checkComboAndAddTag (#bead:beadSpriteNode? , bead2:beadSpriteNode? , bead3:beadSpriteNode? , tag:Int) -> Bool {

		if bead != nil && bead2 != nil && bead3 != nil {

			let checkNewLine = bead3!.tag == 0  || bead2!.tag == 0 || bead!.tag == 0
			let checkCombo = bead2!.type == bead!.type && bead3!.type == bead!.type

			if checkNewLine && checkCombo {
				bead!.tag = tag;
				bead2!.tag = tag;
				bead3!.tag = tag;
				return true
			}
			else {
				return false
			}
		}
		else {
			return false
		}
	}


    func removeCombo(tag:Int) {
        if tag == 0 {
            self.fillBead()
			lockTouch = false
            return
        }

		let time = 0.5
		lockTouch = true
        for column in 0..<6 {
            for row in 0..<5 {
                if var obj:AnyObject? = self.beadInLacation(column:column, row:row) {
                    var bead = obj as beadSpriteNode!
                    if bead.tag == tag {
                        self.runActionBeadCount++
                        var action = SKAction.group([SKAction.scaleTo(1.2, duration: time),SKAction.fadeOutWithDuration(time)])
                        bead.runAction(action, completion: {() in
                            bead.removeFromParent()
                            self.runActionBeadCount--
                            if self.runActionBeadCount == 0 {
								self.removeCombo(tag-1)
                            }
                            })
                    }
                }
            }
        }
    }
}








