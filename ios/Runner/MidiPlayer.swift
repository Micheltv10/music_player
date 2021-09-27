import Foundation
import AVFoundation

class MidiPlayer {
    
    var midiPlayer:AVMIDIPlayer?
    
    var timer:Timer?
    
    func load(url: URL) {
        let soundBankFileName = "FreeFont"
        guard let bankURL = Bundle.main.url(forResource: soundBankFileName, withExtension: "sf2") else {
            fatalError("'\(soundBankFileName).sf2\' file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOf: url, soundBankURL: bankURL)
            print("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        self.midiPlayer?.prepareToPlay()
        self.midiPlayer?.rate = 1.0 // default
        
        print("Duration: \(String(describing: midiPlayer?.duration))")
    }

    func position() -> Int {
        guard let midiPlayer = self.midiPlayer else {
            return 0
        }
        return Int(midiPlayer.currentPosition)
    }
    
    func play() {
        guard let midiPlayer = self.midiPlayer else {
            return
        }
        startTimer()
        midiPlayer.play({
            print("finished")
            midiPlayer.currentPosition = 0
            self.timer?.invalidate()
        })
    }
    
    var isPlaying : Bool {
        return self.midiPlayer?.isPlaying ?? false
    }
    
    func stop() {
        if isPlaying {
            self.midiPlayer?.stop()
            self.timer?.invalidate()
        }
    }
    
    func togglePlaying() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }
    
    @objc func updateTime() {
        print("\(String(describing: midiPlayer?.currentPosition))")
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1,
            target:self,
            selector: #selector(MidiPlayer.updateTime),
            userInfo:nil,
            repeats:true)
    }
    
}

