import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static var currentBackground = "gameBackgroundImage"

    let ballCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    let goalCategory: UInt32 = 0x1 << 2
    let edgeCategory: UInt32 = 0x1 << 3
    let coinsKey = "savedCoins"
    
    var ball: SKShapeNode!
    var coins = 0
    var isDragging = false
    var ballReleased = false
    
    let coinLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    var coinBackground: SKSpriteNode!
    
    var ballStuckTimer: Timer?
    let ballStuckThreshold: TimeInterval = 5.0
    
    private var menuButton: SKSpriteNode!
    
    let bumpSound = SKAction.playSoundFileNamed("bump.mp3", waitForCompletion: false)
    var backgroundMusic: SKAudioNode!
    let musicVolume: Float = 0.3
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        setupBackground()
        setupUI()
        setupBoundaries()
        setupObstacles()
        setupGoals()
        spawnBall()
        setupMenuButton()
        setupBackgroundMusic()
        
        coins = UserDefaults.standard.integer(forKey: coinsKey)
        coinLabel.text = "\(coins)"
        
        ball.physicsBody?.contactTestBitMask = goalCategory | obstacleCategory
    }
    
    func saveCoins() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
    }
    
    func setupBackground() {
        self.childNode(withName: "background")?.removeFromParent()
        
        let background = SKSpriteNode(imageNamed: GameScene.currentBackground)
        background.name = "background"
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -2
        background.size = size
        addChild(background)
    }
    
    func setupUI() {
        coinBackground = SKSpriteNode(imageNamed: "scoreBackgroundImage")
        coinBackground.position = CGPoint(x: size.width * 0.2, y: size.height * 0.9)
        coinBackground.zPosition = 1
        addChild(coinBackground)
        
        coinLabel.text = "\(coins)"
        coinLabel.fontSize = 22
        coinLabel.fontColor = .white
        coinLabel.position = CGPoint.zero
        coinLabel.zPosition = 2
        coinLabel.horizontalAlignmentMode = .center
        coinLabel.verticalAlignmentMode = .center
        coinBackground.addChild(coinLabel)
    }
    
    func setupBoundaries() {
        let edge = SKPhysicsBody(edgeLoopFrom: self.frame)
        edge.categoryBitMask = edgeCategory
        edge.friction = 0
        edge.restitution = 0.5
        self.physicsBody = edge
    }
    
    private func setupMenuButton() {
        menuButton = SKSpriteNode(imageNamed: "menuButtonImage")
        menuButton.position = CGPoint(x: size.width * 0.8, y: size.height * 0.9)
        menuButton.zPosition = 2
        menuButton.name = "menuButton"
        addChild(menuButton)
    }
    
    func spawnBall() {
        ball?.removeFromParent()
        
        ball = SKShapeNode(circleOfRadius: 10)
        let colors: [SKColor] = [.yellow, .red, .orange, .blue, .systemPink]
        ball.fillColor = colors.randomElement() ?? .yellow
        ball.strokeColor = .clear
        ball.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = goalCategory | obstacleCategory
        ball.physicsBody?.collisionBitMask = obstacleCategory | edgeCategory
        ball.physicsBody?.restitution = 0.5
        ball.physicsBody?.isDynamic = false
        
        addChild(ball)
        ballReleased = false
    }
    
    func setupObstacles() {
        let bigGearsPositions = [
            CGPoint(x: size.width * 0.12, y: size.height * 0.7),
            CGPoint(x: size.width * 0.9, y: size.height * 0.7),
            CGPoint(x: size.width / 2, y: size.height * 0.55),
            CGPoint(x: size.width * 0.12, y: size.height * 0.3),
            CGPoint(x: size.width * 0.9, y: size.height * 0.3)
        ]
        
        for pos in bigGearsPositions {
            let gear = SKSpriteNode(imageNamed: "gearImage")
            gear.position = pos
            gear.physicsBody = SKPhysicsBody(circleOfRadius: 40)
            gear.physicsBody?.isDynamic = false
            gear.physicsBody?.categoryBitMask = obstacleCategory
            addChild(gear)
        }
        
        let circlesPositions = [
            CGPoint(x: size.width / 2, y: size.height * 0.7),
            CGPoint(x: size.width * 0.65, y: size.height * 0.7),
            CGPoint(x: size.width * 0.35, y: size.height * 0.7),
            CGPoint(x: size.width * 0.9, y: size.height * 0.52),
            CGPoint(x: size.width * 0.1, y: size.height * 0.52),
            CGPoint(x: size.width * 0.5, y: size.height * 0.4),
            CGPoint(x: size.width * 0.2, y: size.height * 0.4),
            CGPoint(x: size.width * 0.35, y: size.height * 0.4),
            CGPoint(x: size.width * 0.65, y: size.height * 0.4),
            CGPoint(x: size.width * 0.8, y: size.height * 0.4)
        ]
        
        for pos in circlesPositions {
            let circle = SKShapeNode(circleOfRadius: 15)
            circle.fillColor = .white
            circle.strokeColor = .clear
            circle.position = pos
            circle.setScale(0.8)
            circle.physicsBody = SKPhysicsBody(circleOfRadius: 15)
            circle.physicsBody?.isDynamic = false
            circle.physicsBody?.categoryBitMask = obstacleCategory
            addChild(circle)
        }
        
        let spikesPositions = [
            CGPoint(x: size.width * 0.35, y: size.height * 0.63),
            CGPoint(x: size.width * 0.65, y: size.height * 0.63),
            CGPoint(x: size.width * 0.15, y: size.height * 0.58),
            CGPoint(x: size.width * 0.85, y: size.height * 0.58),
            CGPoint(x: size.width * 0.25, y: size.height * 0.52),
            CGPoint(x: size.width * 0.75, y: size.height * 0.52),
            CGPoint(x: size.width * 0.99, y: size.height * 0.4),
            CGPoint(x: size.width * 0.01, y: size.height * 0.4),
            CGPoint(x: size.width * 0.6, y: size.height * 0.3),
            CGPoint(x: size.width * 0.4, y: size.height * 0.3),
            CGPoint(x: size.width * 0.6, y: size.height * 0.2),
            CGPoint(x: size.width * 0.4, y: size.height * 0.2),
            CGPoint(x: size.width * 0.8, y: size.height * 0.2),
            CGPoint(x: size.width * 0.2, y: size.height * 0.2),
            CGPoint(x: size.width * 0.01, y: size.height * 0.2),
            CGPoint(x: size.width * 0.99, y: size.height * 0.2)
        ]
        
        for pos in spikesPositions {
            let spike = SKSpriteNode(imageNamed: "spikeImage")
            spike.position = pos
            spike.setScale(0.8)
            spike.physicsBody = SKPhysicsBody(circleOfRadius: 15)
            spike.physicsBody?.isDynamic = false
            spike.physicsBody?.categoryBitMask = obstacleCategory
            addChild(spike)
        }
    }
    
    func setupGoals() {
        let rewards = [10, 20, 50, 20, 10]
        let slotCount = rewards.count
        let slotWidth: CGFloat = 79
        let spacing = (size.width - CGFloat(slotCount) * slotWidth) / CGFloat(slotCount + 1)
        let yPosition: CGFloat = 40
        
        for (index, reward) in rewards.enumerated() {
            let imageName: String
            switch reward {
            case 10: imageName = "goal10"
            case 20: imageName = "goal20"
            case 50: imageName = "goal50"
            default: imageName = "goal0"
            }
            
            let slot = SKSpriteNode(imageNamed: imageName)
            slot.size = CGSize(width: slotWidth, height: 88)
            
            let xPosition = spacing + CGFloat(index) * (slotWidth + spacing)
            slot.position = CGPoint(x: xPosition + slotWidth / 2, y: yPosition)
            
            slot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: slotWidth, height: 20))
            slot.physicsBody?.isDynamic = false
            slot.physicsBody?.categoryBitMask = goalCategory
            slot.name = "goal_\(index)"
            addChild(slot)
        }
    }
    
    func resetBallStuckTimer() {
        ballStuckTimer?.invalidate()
        ballStuckTimer = Timer.scheduledTimer(withTimeInterval: ballStuckThreshold, repeats: false) { [weak self] _ in
            self?.checkIfBallStuck()
        }
    }
    
    func checkIfBallStuck() {
        guard ballReleased, let velocity = ball.physicsBody?.velocity else { return }
        
        let isMoving = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy) > 10.0
        
        if !isMoving {
            resetBallPosition()
        } else {
            resetBallStuckTimer()
        }
    }
    
    func resetBallPosition() {
        coins = 0
        coinLabel.text = "\(coins)"
        saveCoins()
        
        ball.removeFromParent()
        spawnBall()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, !ballReleased else { return }
        isDragging = false
        ballReleased = true
        
        ball.physicsBody?.isDynamic = true
        resetBallStuckTimer()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard ballReleased else { return }
        
        let goalNode = contact.bodyA.node?.name?.starts(with: "goal_") == true
        ? contact.bodyA.node
        : contact.bodyB.node
        
        if let goalName = goalNode?.name {
            ballStuckTimer?.invalidate()
            
            let reward = rewardForSlot(goalName)
            coins += reward
            coinLabel.text = "\(coins)"
            saveCoins()
            
            ball.removeFromParent()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.spawnBall()
            }
        }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == ballCategory | obstacleCategory {
            playBumpSound()
        }
    }
    
    func setupBackgroundMusic() {
        if let backgroundMusic = self.childNode(withName: "backgroundMusic") {
            backgroundMusic.removeFromParent()
        }
        
        if let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.name = "backgroundMusic"
            backgroundMusic.autoplayLooped = true
            
            backgroundMusic.run(SKAction.changeVolume(to: GameSettings.musicVolume, duration: 0))
            
            addChild(backgroundMusic)
        }
    }
    
    func playBumpSound() {
        guard GameSettings.soundVolume > 0 else { return }

        self.childNode(withName: "bumpSoundNode")?.removeFromParent()

        if let bumpSoundURL = Bundle.main.url(forResource: "bump", withExtension: "mp3") {
            let bumpSound = SKAudioNode(url: bumpSoundURL)
            bumpSound.name = "bumpSoundNode"
            bumpSound.autoplayLooped = false
            
            addChild(bumpSound)
            
            bumpSound.run(SKAction.changeVolume(to: GameSettings.soundVolume, duration: 0))
            
            bumpSound.run(SKAction.play())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bumpSound.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if menuButton.contains(location) {
            goToStartScene()
            return
        }
        
        guard !ballReleased else { return }
        isDragging = true
    }
    
    private func goToStartScene() {
        let startScene = StartScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(startScene, transition: transition)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, !ballReleased, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let newX = max(20, min(location.x, size.width - 20)) 
        ball.position = CGPoint(x: newX, y: ball.position.y)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func rewardForSlot(_ name: String) -> Int {
        switch name {
        case "goal_0": return 10
        case "goal_1": return 20
        case "goal_2": return 50
        case "goal_3": return 20
        case "goal_4": return 10
        default: return 0
        }
    }
}
