import SpriteKit

class beadSpriteNode : SKSpriteNode {
    
	var tag:Int = 0
	var type:Int = 0
    var finalPosition:CGPoint = CGPointZero
    
    class func createBead (#column:Int,row:Int) -> beadSpriteNode {
        let beadColor = ["bead_yellow","bead_green","bead_puple","bead_blue","bead_red","bead_gray"]
        let chooseType = Int( arc4random() % 4)
        let beadTexture = SKTexture(imageNamed:beadColor[chooseType])
        let bead = beadSpriteNode(texture: beadTexture)
        bead.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        bead.startPosition(column: column, row: row)
        bead.finalPosition(column: column, row: row)
        bead.type = chooseType
        return bead
    }
    
    func startPosition (#column:Int,row:Int) {
        self.position = CGPoint(x: column * 53 + 28, y: row * 53 + 266)
    }

    func finalPosition (#column:Int,row:Int) {
        self.finalPosition = CGPoint(x: column * 53 + 28, y: row * 53)
    }
}