//
//  ViewController.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 27/3/2022.
//

import Cocoa

import MediaPlayer
import AudioToolbox


class ViewController: NSViewController {
    
    // TODO: SHOW ON EVERY PAGE
    // TODO: DOUBLE CLICK TO SHOW SONG ON SPOTIFY
    
    @IBOutlet weak var controlView: NSVisualEffectView!
    
    @IBOutlet var albumArtworkImageView: NSImageView!
    @IBOutlet weak var volumeImageView: NSImageView!
    
    @IBOutlet weak var songLabelView: NSVisualEffectView!
    @IBOutlet weak var songNameLabel: NSTextField!
    @IBOutlet weak var songArtistLabel: NSTextField!
    @IBOutlet weak var totalTimeLabel: NSTextField!
    @IBOutlet weak var timePassedLabel: NSTextField!
    @IBOutlet weak var controlViewSongNameLabel: NSTextField!
    @IBOutlet weak var controlViewSongArtistAlbumLabel: NSTextField!
    
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var repeatButton: NSButton!
    @IBOutlet weak var shuffleButton: NSButton!
    @IBOutlet weak var exitButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var muteButton: NSButton!
    @IBOutlet weak var skipForwardButton: NSButton!
    @IBOutlet weak var skipBackButton: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var timeSlider: NSSlider!
    
    @IBOutlet weak var timeProgressView: NSProgressIndicator!
    
    @IBOutlet var settingsMenu: NSMenu!
    
    var mouseIsInControlView: Bool = false
    var lastVolume: Float = 0
    var isMuted: Bool = false
    
    let tintColor = NSColor(calibratedRed: 160 / 255, green: 117 / 255, blue: 211 / 255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure album artwork image view
        if let albumArtworkImageView = albumArtworkImageView {
            albumArtworkImageView.imageScaling = .scaleAxesIndependently
        }
        
        // Configure song label view
        if let songLabelView = songLabelView {
            songLabelView.wantsLayer = true
            songLabelView.layer?.cornerRadius = 10
        }
        
        // Configure control view
        if let controlView = controlView {
            controlView.alphaValue = 0
        }
        
        // Load song data
        Spotify.shared.updateSongData()
        self.reloadView()
        
        // Create timer to check for the currently playing song
        var _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForNewSong), userInfo: nil, repeats: true)
        
        let trackingRect = self.view.frame
        let trackingArea = NSTrackingArea(rect: trackingRect, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        self.view.addTrackingArea(trackingArea)
        
        // Set song playing state
        self.updatePlayPauseButton()
        
        // Volume slider
        let currentVolumeInteger = Int(self.getVolume() * 100)
        if let volumeSlider = volumeSlider {
            volumeSlider.integerValue = currentVolumeInteger
            volumeSlider.controlSize = .mini
            if let _ = volumeImageView {
                self.setVolumeImageView(volumeLevel: currentVolumeInteger)
            }
            self.lastVolume = getVolume()
            if (self.lastVolume == 0) {
                self.isMuted = true
            } else {
                self.isMuted = false
            }
        }
        
        
        // Time slider
        self.updateTimeSlider()
        var _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeSlider), userInfo: nil, repeats: true)
        
        // Shuffle button
        if let shuffleButton = self.shuffleButton {
            Spotify.shared.isShuffling { shuffling in
                if (shuffling) {
                    shuffleButton.contentTintColor = self.tintColor
                } else {
                    shuffleButton.contentTintColor = .secondaryLabelColor
                }
            }
        }
        
        
        // Repeat button
        if let repeatButton = repeatButton {
            Spotify.shared.isRepeating { repeating in
                if (repeating) {
                    repeatButton.contentTintColor = self.tintColor
                } else {
                    repeatButton.contentTintColor = .secondaryLabelColor
                }
            }
        }
        
        
        // State changes to poll for
        var _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pollForChanges), userInfo: nil, repeats: true)
        
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseIsInControlView = true
        showControlView()
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseIsInControlView = false
        hideControlView()
    }
    
    override func mouseUp(with event: NSEvent) {
        if (event.clickCount == 2) {
            self.openSongInSpotify()
        }
    }
    
    @objc func checkForNewSong() {
        let currentSongName = Spotify.shared.getCurrentSongName()
        if (currentSongName != Spotify.shared.currentSong.name) {
            Spotify.shared.updateSongData()
            if (currentSongName == "") {
                self.loadNoSongPlayingView()
            }
            self.reloadView()
            
            
        }
    }
    
    @objc func updateTimeSlider() {
        Spotify.shared.getCurrentSliderPosition { position in
            DispatchQueue.main.async { [self] in
                let integerPosition = Int(position)
                let totalDuration = Spotify.shared.currentSong.duration
                // Set time slider
                if let timeSlider = self.timeSlider {
                    timeSlider.maxValue = totalDuration
                    timeSlider.integerValue = integerPosition
                }
                
                // Set time progress view
                if let timeProgressView = timeProgressView {
                    timeProgressView.maxValue = totalDuration
                    
                }
                
                // Set labels
                if let timePassedLabel = timePassedLabel, let totalTimeLabel = totalTimeLabel {
                    timePassedLabel.stringValue = self.secondsToMinutes(seconds: integerPosition)
                    totalTimeLabel.stringValue = self.secondsToMinutes(seconds: Int(totalDuration))
                }
                
            }
            
        }
    }
    
    @objc func pollForChanges() {
        updatePlayPauseButton()
        updateRepeatingButton()
        updateShufflingButton()
    }
    
    func loadNoSongPlayingView() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        if let albumArtworkImageView = albumArtworkImageView {
            
            albumArtworkImageView.layer?.add(transition, forKey: nil)
            albumArtworkImageView.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "")
            
        }
    }
    
    func openSongInSpotify() {
        Spotify.shared.getSongUrl { songUrl in
            if let url = URL(string: songUrl) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func updateTimeLabels() {
        Spotify.shared.getCurrentSliderPosition { position in
            DispatchQueue.main.async {
                let integerPosition = Int(position)
                let totalDuration = Spotify.shared.currentSong.duration
                self.timePassedLabel.stringValue = self.secondsToMinutes(seconds: integerPosition)
                self.totalTimeLabel.stringValue = self.secondsToMinutes(seconds: Int(totalDuration))
            }
        }
    }
    
    func reloadView() {
        self.setAlbumArtwork()
        self.setSongLabels()
    }
    
    func setSongLabels() {
        if let songNameLabel = songNameLabel {
            songNameLabel.stringValue = Spotify.shared.currentSong.name
        }
        
        if let controlViewSongNameLabel = controlViewSongNameLabel {
            controlViewSongNameLabel.stringValue = Spotify.shared.currentSong.name
        }
        
        if let songArtistLabel = songArtistLabel {
            songArtistLabel.stringValue = Spotify.shared.currentSong.artist
        }
        
        if let controlViewSongArtistAlbumLabel = controlViewSongArtistAlbumLabel {
            controlViewSongArtistAlbumLabel.stringValue = "\(Spotify.shared.currentSong.artist) - \(Spotify.shared.currentSong.album)"
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        guard let button = appDelegate.statusItem.button else {
            return
        }
        button.title = "\(Spotify.shared.currentSong.name) - \(Spotify.shared.currentSong.artist)"
        
    }
    
    func setAlbumArtwork() {
        if let url = URL(string: Spotify.shared.currentSong.albumArtworkUrl) {
            downloadImage(from: url)
        }
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                if let albumArtworkImageView = self?.albumArtworkImageView {
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = .fade
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    
                    
                    albumArtworkImageView.layer?.add(transition, forKey: nil)
                    albumArtworkImageView.image = NSImage(data: data)
                    
                }
            }
        }
    }
    
    func showControlView() {
        if let controlView = controlView {
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = .fade
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            controlView.layer?.add(transition, forKey: nil)
            controlView.alphaValue = 1
            controlView.isHidden = false
        }
    }
    
    func hideControlView() {
        if let controlView = controlView {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                controlView.animator().alphaValue = 0
            } completionHandler: {
                controlView.isHidden = true
                controlView.alphaValue = 1
                if self.mouseIsInControlView {
                    self.showControlView()
                }
            }
        }
    }
    
    func updatePlayPauseButton() {
        if let playPauseButton = playPauseButton {
            Spotify.shared.isPlaying(completionHandler: { playing in
                if (playing) {
                    playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
                } else {
                    playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
                }
            })
        }
    }
    
    func setVolume(level: Float) {
        // Get default output device
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        _ = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        // Set volume
        var volume = Float32(level)
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain)
        
        _ = AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)
    }
    
    func getVolume() -> Float {
        // Get default output device
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        _ = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        // Get volume
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain)
        
        _ = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            &volumeSize,
            &volume)
        return volume
    }
    
    func setVolumeImageView(volumeLevel: Int) {
        if let volumeImageView = volumeImageView {
            if (volumeLevel == 0) {
                volumeImageView.image = NSImage(systemSymbolName: "speaker.fill", accessibilityDescription: "")
            } else if (volumeLevel > 0 && volumeLevel <= 33) {
                volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.1.fill", accessibilityDescription: "")
            } else if (volumeLevel > 33 && volumeLevel <= 67) {
                volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "")
            } else {
                volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.3.fill", accessibilityDescription: "")
            }
        }
    }
    
    func secondsToMinutes(seconds: Int) -> String {
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: date)
        let newDate = start.addingTimeInterval(TimeInterval(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "m:ss"
        return formatter.string(from: newDate)
    }
    
    func setShufflingState() {
        if let shuffleButton = shuffleButton {
            Spotify.shared.isShuffling { shuffling in
                if (shuffling) {
                    Spotify.shared.setShuffling(shuffling: false)
                    shuffleButton.contentTintColor = .secondaryLabelColor
                    return
                }
                Spotify.shared.setShuffling(shuffling: true)
                shuffleButton.contentTintColor = self.tintColor
            }
        }
    }
    
    func updateShufflingButton() {
        if let shuffleButton = shuffleButton {
            Spotify.shared.isShuffling { shuffling in
                if (shuffling) {
                    shuffleButton.contentTintColor = self.tintColor
                    return
                }
                shuffleButton.contentTintColor = .secondaryLabelColor
            }
        }
    }
    
    func setRepeatingState() {
        if let repeatButton = repeatButton {
            Spotify.shared.isRepeating { repeating in
                if (repeating) {
                    Spotify.shared.setRepeating(repeating: false)
                    repeatButton.contentTintColor = .secondaryLabelColor
                    return
                }
                Spotify.shared.setRepeating(repeating: true)
                repeatButton.contentTintColor = self.tintColor
            }
        }
    }
    
    func updateRepeatingButton() {
        if let repeatButton = repeatButton {
            Spotify.shared.isRepeating { repeating in
                if (repeating) {
                    repeatButton.contentTintColor = self.tintColor
                    return
                }
                repeatButton.contentTintColor = .secondaryLabelColor
            }
        }
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if let playPauseButton = playPauseButton {
            Spotify.shared.playOrPause() { playerState in
                if (playerState == "playing") {
                    playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
                } else {
                    playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
                }
            }
        }
    }
    
    @IBAction func nextSongClicked(_ sender: Any) {
        if let playPauseButton = playPauseButton {
            Spotify.shared.nextSong() {
                playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
            }
        }
    }
    
    @IBAction func previousSongClicked(_ sender: Any) {
        if let playPauseButton = playPauseButton {
            Spotify.shared.previousSong() {
                playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
            }
        }
    }
    
    @IBAction func volumeSliderChanged(_ sender: NSSlider) {
        let sliderLevel = sender.integerValue
        self.setVolume(level: Float(sliderLevel) / 100)
        self.setVolumeImageView(volumeLevel: sliderLevel)
    }
    
    @IBAction func timeSliderChanged(_ sender: NSSlider) {
        Spotify.shared.scrubSong(position: Double(sender.integerValue))
        self.updateTimeLabels()
    }
    
    @IBAction func muteClicked(_ sender: Any) {
        if let volumeSlider = volumeSlider, let muteButton = muteButton {
            if (self.isMuted) {
                self.isMuted = false
                self.setVolume(level: lastVolume)
                let lastVolumeInt = Int(self.lastVolume * 100)
                volumeSlider.integerValue = lastVolumeInt
                self.setVolumeImageView(volumeLevel: lastVolumeInt)
                muteButton.contentTintColor = .secondaryLabelColor
            } else {
                self.lastVolume = self.getVolume()
                self.isMuted = true
                volumeSlider.integerValue = 0
                self.setVolume(level: 0)
                self.setVolumeImageView(volumeLevel: 0)
                muteButton.contentTintColor = self.tintColor
            }
        }
    }
    
    @IBAction func exitClicked(_ sender: NSButton) {
        sender.window?.close()
    }
    
    @IBAction func skipBackClicked(_ sender: Any) {
        Spotify.shared.skipBack(seconds: 15)
        self.updateTimeSlider()
    }
    
    @IBAction func skipForwardClicked(_ sender: Any) {
        Spotify.shared.skipForward(seconds: 15)
        self.updateTimeSlider()
    }
    
    @IBAction func shuffleClicked(_ sender: Any) {
        setShufflingState()
    }
    
    @IBAction func repeatClicked(_ sender: Any) {
        setRepeatingState()
    }
    
    @IBAction func settingsButtonClicked(_ sender: NSButtonCell) {
        settingsMenu.popUp(positioning: settingsMenu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        
    }
    
}


extension ViewController {
    
    static func freshController() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("MenuBarViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Can't find MenuBarViewController. Check Main.storyboard")
        }
        return viewcontroller
    }
}
