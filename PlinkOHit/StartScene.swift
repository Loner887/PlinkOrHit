import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupButtons()
        loadSettings()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "startBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
    }
    
    private func setupButtons() {
        let startButton = SKSpriteNode(imageNamed: "startButtonImage")
        startButton.name = "startButton"
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        startButton.zPosition = 1
        addChild(startButton)
        
        let aboutButton = SKSpriteNode(imageNamed: "settingsButtonImage")
        aboutButton.name = "settingsButton"
        aboutButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        aboutButton.zPosition = 1
        addChild(aboutButton)
        
        let privacyButton = SKSpriteNode(imageNamed: "privacyButtonImage")
        privacyButton.name = "privacyButton"
        privacyButton.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        privacyButton.zPosition = 1
        addChild(privacyButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "startButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1))
        } else if touchedNode.name == "settingsButton" {
            goToSettings()
        } else if touchedNode.name == "privacyButton" {
            openPrivacyPolicy()
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://doc-hosting.flycricket.io/plink-o-hit-privacy-policy/03858165-dd9e-47bc-9dd3-619aff432f29/privacy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        GameSettings.musicVolume = defaults.float(forKey: "musicVolume")
        GameSettings.soundVolume = defaults.float(forKey: "soundVolume")
        
        if defaults.object(forKey: "musicVolume") == nil {
            GameSettings.musicVolume = 0.5
            defaults.set(GameSettings.musicVolume, forKey: "musicVolume")
        }
        if defaults.object(forKey: "soundVolume") == nil {
            GameSettings.soundVolume = 0.5
            defaults.set(GameSettings.soundVolume, forKey: "soundVolume")
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(GameSettings.musicVolume, forKey: "musicVolume")
        defaults.set(GameSettings.soundVolume, forKey: "soundVolume")
    }
    
    func goToSettings() {
        saveSettings()
        let settingsScene = SettingsScene(size: self.size)
        settingsScene.scaleMode = .aspectFill
        view?.presentScene(settingsScene, transition: SKTransition.fade(withDuration: 1))
    }
}
