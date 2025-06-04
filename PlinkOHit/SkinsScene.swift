import SpriteKit

class SkinsScene: SKScene {
    
    let coinsKey = "savedCoins"
    var coins: Int = 0
    
    let backgrounds = [
        (name: "gameBackground1", position: CGPoint(x: 0.3, y: 0.7)),
        (name: "gameBackground2", position: CGPoint(x: 0.7, y: 0.7)),
        (name: "gameBackground3", position: CGPoint(x: 0.5, y: 0.4))
    ]
    
    override func didMove(to view: SKView) {
        coins = UserDefaults.standard.integer(forKey: coinsKey)
        setupUI()
        createBackgroundButtons()
    }
    
    func setupUI() {
        let background = SKSpriteNode(imageNamed: "skinBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
        
        let backButton = SKSpriteNode(imageNamed: "backButtonImage")
        backButton.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        backButton.name = "backButton"
        backButton.zPosition = 1
        addChild(backButton)
        
    }
    
    func createBackgroundButtons() {
        for (index, bg) in backgrounds.enumerated() {
            guard let buttonImage = UIImage(named: "skinButton_\(index+1)") else {
                print("Error: Could not load image for skinButton_\(index+1)")
                continue
            }
            
            let button = SKSpriteNode(texture: SKTexture(image: buttonImage))
            
            let absolutePosition = CGPoint(
                x: size.width * bg.position.x,
                y: size.height * bg.position.y
            )
            
            button.position = absolutePosition
            button.name = "bgButton_\(index)"
            button.zPosition = 1
            addChild(button)
            
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let nodes = nodes(at: location)
        
        for node in nodes {
            
            if node.name == "backButton" {
                goBackToStartScene()
                return
            }
            
            if let nodeName = node.name, nodeName.hasPrefix("bgButton_") {
                let indexString = nodeName.replacingOccurrences(of: "bgButton_", with: "")
                if let index = Int(indexString) {
                    buyBackground(index: index)
                } else {
                }
            }
        }
    }
    
    func buyBackground(index: Int) {
        guard index < backgrounds.count else { return }
        
        if coins >= 50 {
            coins -= 50
            UserDefaults.standard.set(coins, forKey: coinsKey)
            
            GameScene.currentBackground = backgrounds[index].name
            UserDefaults.standard.set(backgrounds[index].name, forKey: "selectedBackground")
            
            showMessage("Background changed!")
        } else {
            showMessage("Not enough coins!")
        }
    }
    
    func showMessage(_ text: String) {
        let message = SKLabelNode(text: text)
        message.fontName = "Avenir-Black"
        message.fontSize = 30
        message.fontColor = .white
        message.position = CGPoint(x: size.width/2, y: size.height / 2)
        message.zPosition = 10
        
        let background = SKShapeNode(rectOf: CGSize(width: message.frame.width + 40, height: message.frame.height + 20))
        background.fillColor = SKColor(white: 0, alpha: 1)
        background.position = message.position
        background.zPosition = 9
        background.name = "messageBackground"
        
        addChild(background)
        addChild(message)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.wait(forDuration: 1.5), fadeOut, remove])
        
        message.run(sequence)
        background.run(sequence)
    }
    
    func goBackToStartScene() {
        let startScene = StartScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(startScene, transition: transition)
    }
}
