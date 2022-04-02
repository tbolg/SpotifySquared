//
//  Spotify.swift
//  MusicWidget
//
//  Created by Tomas Bolger on 28/3/2022.
//

import Foundation
import CoreMedia

class Spotify: NSObject {
    
    static let shared = Spotify()
    var currentSong: Song
    
    override init() {
        currentSong = Song()
    }
    
    public func updateSongData() {
        self.loadCurrentSongName()
        self.loadCurrentAlbum()
        self.loadCurrentArtist()
        self.loadSpotifyAlbumArtwork()
        self.getSongDuration { duration in
            self.currentSong.duration = duration
        }
    }
    
    func loadSpotifyAlbumArtwork() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                    return artwork url of current track
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            
            self.currentSong.albumArtworkUrl = out?.stringValue ?? ""
        })
    }
    
    func loadCurrentSongName() {
        let script =  """
            if application "Spotify" is running then
                tell application "Spotify"
                    if player state is playing then
                        return name of current track
                    else
                        return ""
                end if
                end tell
            else
                return ""
            end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            
            self.currentSong.name = out?.stringValue ?? ""
        })
    }
    
    func getCurrentSongName() -> String {
        let script =  """
            if application "Spotify" is running then
                tell application "Spotify"
                    if player state is playing then
                        return name of current track
                    else
                        return ""
                end if
                end tell
            else
                return ""
            end if
        """
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        let output = appleScript?.executeAndReturnError(&error)
        return output?.stringValue ?? ""
    }
    
    func loadCurrentAlbum() {
        let script = """
            if application "Spotify" is running then
                tell application "Spotify"
                    return album of current track
                end tell
            end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            
            self.currentSong.album = out?.stringValue ?? ""
        })
    }
    
    func loadCurrentArtist() {
        let script = """
            if application "Spotify" is running then
                tell application "Spotify"
                    return artist of current track
                end tell
            else
                return ""
            end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            
            self.currentSong.artist = out?.stringValue ?? ""
        })
    }
    
    func nextSong() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    play (next track)
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func previousSong() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    play (previous track)
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func playOrPause() {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to set spotifyState to (player state as text)
            if spotifyState is equal to "playing" then
                tell application "Spotify" to playpause
            else
                tell application "Spotify" to play
            end if
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func isPlaying(completionHandler: @escaping (Bool) -> Void) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to set spotifyState to (player state as text)
            return spotifyState
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            let result = out?.stringValue ?? ""
            if result == "playing" {
                self.currentSong.isPlaying = true
                completionHandler(true)
                return
            }
            self.currentSong.isPlaying = false
            completionHandler(false)
            return
        })
    }
    
    func scrubSong(position: Double) {
        let script = """
        tell application "Spotify"
            if player state is playing then
                set player position to "\(position)"
            end if
        end tell
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func getSongDuration(completionHandler: @escaping (Double) -> Void) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return (duration of current track) / 1000
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            let duration = Double(out?.stringValue ?? "") ?? 0
            completionHandler(duration)
        })
        
    }
    
    func getCurrentSliderPosition(completionHandler: @escaping (Double) -> Void) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return player position
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            let currentPosition = Double(out?.stringValue ?? "") ?? 0
            completionHandler(currentPosition)
        })
    }
    
    func skipBack(seconds: Double) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    set player position to (player position - \(seconds))
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func skipForward(seconds: Double) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    set player position to (player position + \(seconds))
                else
                    return ""
                end if
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func setShuffling(shuffling: Bool) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                set shuffling to \(shuffling)
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func isShuffling(completionHandler: @escaping (Bool) -> Void) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to return shuffling
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            let result = out?.stringValue ?? ""
            if (result == "true") {
                completionHandler(true)
                return
            }
            completionHandler(false)
            return
        })
    }
    
    func setRepeating(repeating: Bool) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                set repeating to \(repeating)
            end tell
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
        })
    }
    
    func isRepeating(completionHandler: @escaping (Bool) -> Void) {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify" to return repeating
        end if
        """
        NSAppleScript.go(code: script, completionHandler: {_ , out, err in
            if let err = err {
                print(err)
            }
            let result = out?.stringValue ?? ""
            if (result == "true") {
                completionHandler(true)
                return
            }
            completionHandler(false)
            return
        })
    }
    
}


