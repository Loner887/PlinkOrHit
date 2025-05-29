import SpriteKit

struct GameSettings {
    static var musicVolume: Float = 0.5
    static var soundVolume: Float = 0.5
}

class SettingsScene: SKScene {
    
    private var slider1Fill: SKSpriteNode!
    private var slider2Fill: SKSpriteNode!
    
    private var selectedSlider: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupSliders()
        setupBackButton()
        
        slider1Fill.xScale = CGFloat(GameSettings.musicVolume)
        slider2Fill.xScale = CGFloat(GameSettings.soundVolume)
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "settingsBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupSliders() {
        let sliderYPositions = [size.height * 0.68, size.height * 0.55]
        
        for (index, yPos) in sliderYPositions.enumerated() {
            let sliderBackground = SKSpriteNode(imageNamed: "sliderBackground")
            sliderBackground.position = CGPoint(x: size.width / 2, y: yPos)
            sliderBackground.zPosition = 1
            sliderBackground.name = "sliderBackground\(index + 1)"
            addChild(sliderBackground)
            
            let sliderFill = SKSpriteNode(imageNamed: "sliderFill")
            sliderFill.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            sliderFill.position = CGPoint(x: -sliderBackground.size.width / 2, y: 0)
            sliderFill.zPosition = 2
            sliderFill.xScale = 0.5
            sliderFill.name = "sliderFill\(index + 1)"
            sliderBackground.addChild(sliderFill)
            
            if index == 0 {
                slider1Fill = sliderFill
            } else {
                slider2Fill = sliderFill
            }
        }
    }
    
    private func setupBackButton() {
        let backButton = SKSpriteNode(imageNamed: "backButtonImage")
        backButton.name = "backButton"
        backButton.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        backButton.zPosition = 2
        addChild(backButton)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    private func handleTouch(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        if node.name == "backButton" {
            let defaults = UserDefaults.standard
            defaults.set(GameSettings.musicVolume, forKey: "musicVolume")
            defaults.set(GameSettings.soundVolume, forKey: "soundVolume")
            
            let startScene = StartScene(size: size)
            startScene.scaleMode = .aspectFill
            view?.presentScene(startScene, transition: SKTransition.fade(withDuration: 1))
        }
        
        if let slider = slider1Fill?.parent, slider.contains(location) {
            updateSlider(sliderFill: slider1Fill, location: location)
        } else if let slider = slider2Fill?.parent, slider.contains(location) {
            updateSlider(sliderFill: slider2Fill, location: location)
        }
    }
    
    private func updateSlider(sliderFill: SKSpriteNode, location: CGPoint) {
        guard let sliderBackground = sliderFill.parent as? SKSpriteNode else { return }
        
        let locationInSlider = convert(location, to: sliderBackground)
        let sliderWidth = sliderBackground.size.width
        let localX = max(min(locationInSlider.x, sliderWidth / 2), -sliderWidth / 2)
        
        let fillRatio = (localX + sliderWidth / 2) / sliderWidth
        sliderFill.xScale = fillRatio
        
        if sliderFill == slider1Fill {
            GameSettings.musicVolume = Float(fillRatio)
        } else if sliderFill == slider2Fill {
            GameSettings.soundVolume = Float(fillRatio)
            updateMusicVolume()
        }
    }
    
    private func updateMusicVolume() {
        if let backgroundMusic = self.childNode(withName: "backgroundMusic") as? SKAudioNode {
            backgroundMusic.run(SKAction.changeVolume(to: GameSettings.musicVolume, duration: 0))
        }
    }
    
}
