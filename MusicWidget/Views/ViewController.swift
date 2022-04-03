//
//  ViewController.swift
//  MusicWidget
//
//  Created by Tomas Bolger on 27/3/2022.
//

import Cocoa

import MediaPlayer
import AudioToolbox


class ViewController: NSViewController {
    
    // TODO: SHOW ON EVERY PAGE
    // TODO: DOUBLE CLICK TO SHOW SONG ON SPOTIFY
    
    @IBOutlet weak var albumArtworkImageView: NSImageView!
    @IBOutlet weak var songLabelView: NSVisualEffectView!
    @IBOutlet weak var songNameLabel: NSTextField!
    @IBOutlet weak var songArtistLabel: NSTextField!
    
    @IBOutlet weak var controlView: NSVisualEffectView!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var repeatButton: NSButton!
    @IBOutlet weak var shuffleButton: NSButton!
    @IBOutlet weak var exitButton: NSButton!
    @IBOutlet weak var likeButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var totalTimeLabel: NSTextField!
    @IBOutlet weak var timePassedLabel: NSTextField!
    @IBOutlet weak var controlViewSongNameLabel: NSTextField!
    @IBOutlet weak var controlViewSongArtistAlbumLabel: NSTextField!
    @IBOutlet weak var volumeImageView: NSImageView!
    
    var mouseIsInControlView: Bool = false
    
    let tintColor = NSColor(calibratedRed: 160 / 255, green: 117 / 255, blue: 211 / 255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure views
        albumArtworkImageView.imageScaling = .scaleAxesIndependently
        songLabelView.wantsLayer = true
        songLabelView.layer?.cornerRadius = 10
        controlView.alphaValue = 0
        
        // Configure sliders
        self.timeSlider.controlSize = .mini
        self.volumeSlider.controlSize = .mini
        
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
        self.volumeSlider.isContinuous = true
        let currentVolumeInteger = Int(self.getVolume() * 100)
        self.volumeSlider.integerValue = currentVolumeInteger
        self.setVolumeImageView(volumeLevel: currentVolumeInteger)
        
        // Time slider
        self.timeSlider.wantsLayer = true
        self.timeSlider.trackFillColor = .white
        self.timeSlider.isContinuous = true
        self.updateTimeSlider()
        var _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeSlider), userInfo: nil, repeats: true)
        
        // Shuffle button
        Spotify.shared.isShuffling { shuffling in
            if (shuffling) {
                self.shuffleButton.contentTintColor = self.tintColor
            } else {
                self.shuffleButton.contentTintColor = .secondaryLabelColor
            }
        }
        
        // Repeat button
        Spotify.shared.isRepeating { repeating in
            if (repeating) {
                self.repeatButton.contentTintColor = self.tintColor
            } else {
                self.repeatButton.contentTintColor = .secondaryLabelColor
            }
        }
        
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseIsInControlView = true
        showControlView()
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseIsInControlView = false
        hideControlView()
    }
    
    @objc func checkForNewSong() {
        let currentSongName = Spotify.shared.getCurrentSongName()
        if (currentSongName != Spotify.shared.currentSong.name) {
            Spotify.shared.updateSongData()
            self.reloadView()
        }
    }
    
    @objc func updateTimeSlider() {
        Spotify.shared.getCurrentSliderPosition { position in
            DispatchQueue.main.async {
                let integerPosition = Int(position)
                let totalDuration = Spotify.shared.currentSong.duration
                // Set time slider
                self.timeSlider.maxValue = totalDuration
                self.timeSlider.integerValue = integerPosition
                
                // Set labels
                self.timePassedLabel.stringValue = self.secondsToMinutes(seconds: integerPosition)
                self.totalTimeLabel.stringValue = self.secondsToMinutes(seconds: Int(totalDuration))
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
        self.songNameLabel.stringValue = Spotify.shared.currentSong.name
        self.controlViewSongNameLabel.stringValue = Spotify.shared.currentSong.name
        self.songArtistLabel.stringValue = Spotify.shared.currentSong.artist
        self.controlViewSongArtistAlbumLabel.stringValue = "\(Spotify.shared.currentSong.artist) - \(Spotify.shared.currentSong.album)"
        
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
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = .fade
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                self?.albumArtworkImageView.layer?.add(transition, forKey: nil)
                self?.albumArtworkImageView.image = NSImage(data: data)
            }
        }
    }
    
    func showControlView() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.controlView.layer?.add(transition, forKey: nil)
        self.controlView.alphaValue = 1
        self.controlView.isHidden = false
    }
    
    func hideControlView() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            self.controlView.animator().alphaValue = 0
        } completionHandler: {
            self.controlView.isHidden = true
            self.controlView.alphaValue = 1
            if self.mouseIsInControlView {
                self.showControlView()
            }
        }
    }
    
    func updatePlayPauseButton() {
        Spotify.shared.isPlaying(completionHandler: { playing in
            print(playing)
            if (playing) {
                self.playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
            } else {
                self.playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
            }
        })
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
        if (volumeLevel == 0) {
            self.volumeImageView.image = NSImage(systemSymbolName: "speaker.fill", accessibilityDescription: "")
        } else if (volumeLevel > 0 && volumeLevel <= 33) {
            self.volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.1.fill", accessibilityDescription: "")
        } else if (volumeLevel > 33 && volumeLevel <= 67) {
            self.volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "")
        } else {
            self.volumeImageView.image = NSImage(systemSymbolName: "speaker.wave.3.fill", accessibilityDescription: "")
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
        Spotify.shared.isShuffling { shuffling in
            if (shuffling) {
                Spotify.shared.setShuffling(shuffling: false)
                self.shuffleButton.contentTintColor = .secondaryLabelColor
                return
            }
            Spotify.shared.setShuffling(shuffling: true)
            self.shuffleButton.contentTintColor = self.tintColor
        }
    }
    
    func setRepeatingState() {
        Spotify.shared.isRepeating { repeating in
            if (repeating) {
                Spotify.shared.setRepeating(repeating: false)
                self.repeatButton.contentTintColor = .secondaryLabelColor
                return
            }
            Spotify.shared.setRepeating(repeating: true)
            self.repeatButton.contentTintColor = self.tintColor
        }
    }
    
    @IBAction func playPauseClicked(_ sender: Any) {
        Spotify.shared.playOrPause() { playerState in
            if (playerState == "playing") {
                self.playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
            } else {
                self.playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
            }
        }
        
    }
    
    @IBAction func nextSongClicked(_ sender: Any) {
        Spotify.shared.nextSong() {
            self.playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
        }
    }
    
    @IBAction func previousSongClicked(_ sender: Any) {
        Spotify.shared.previousSong() {
            self.playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
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
        self.volumeSlider.integerValue = 0
        self.setVolume(level: 0)
        self.setVolumeImageView(volumeLevel: 0)
        // TODO: On click to unmute, set to last volume
    }
    
    @IBAction func exitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
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
}

