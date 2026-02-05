import AVFoundation
import Foundation

final class NoiseEngine: @unchecked Sendable {
    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var currentNoiseType: NoiseType?

    // Use a lock for thread-safe access to mutable state from audio thread
    private let lock = NSLock()

    // Brown noise state
    private var brownNoiseLastOutput: Float = 0.0

    // Pink noise state (Voss-McCartney algorithm)
    private var pinkNoiseGenerators: [Float] = Array(repeating: 0.0, count: 16)
    private var pinkNoiseCounter: UInt32 = 0

    private var _isPlaying: Bool = false
    private var _volume: Float = 0.7

    var isPlaying: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isPlaying
    }

    private var volume: Float {
        lock.lock()
        defer { lock.unlock() }
        return _volume
    }

    init() {}

    func play(type: NoiseType) {
        lock.lock()
        let wasPlaying = _isPlaying
        let wasType = currentNoiseType
        lock.unlock()

        // If already playing this type, just continue
        if wasPlaying && wasType == type {
            return
        }

        // Stop current playback if any
        stop()

        lock.lock()
        currentNoiseType = type
        resetNoiseStateUnsafe()
        lock.unlock()

        let engine = AVAudioEngine()

        let mainMixer = engine.mainMixerNode
        let outputFormat = mainMixer.outputFormat(forBus: 0)

        // Create source node that generates samples
        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            self.lock.lock()
            let currentVolume = self._volume
            self.lock.unlock()

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                self.lock.lock()
                let sample = self.generateSampleUnsafe(for: type)
                self.lock.unlock()

                let adjustedSample = sample * currentVolume

                for buffer in ablPointer {
                    let buf = buffer.mData?.assumingMemoryBound(to: Float.self)
                    buf?[frame] = adjustedSample
                }
            }

            return noErr
        }

        let format = AVAudioFormat(standardFormatWithSampleRate: outputFormat.sampleRate, channels: 2)!

        engine.attach(node)
        engine.connect(node, to: mainMixer, format: format)

        do {
            try engine.start()
            lock.lock()
            audioEngine = engine
            sourceNode = node
            _isPlaying = true
            lock.unlock()
        } catch {
            print("Failed to start audio engine: \(error)")
            lock.lock()
            _isPlaying = false
            lock.unlock()
        }
    }

    func stop() {
        lock.lock()
        let engine = audioEngine
        let node = sourceNode
        audioEngine = nil
        sourceNode = nil
        _isPlaying = false
        currentNoiseType = nil
        lock.unlock()

        engine?.stop()
        if let node = node {
            engine?.detach(node)
        }
    }

    func setVolume(_ newVolume: Float) {
        lock.lock()
        _volume = max(0, min(1, newVolume))
        lock.unlock()
    }

    // MARK: - Private (must be called with lock held)

    private func resetNoiseStateUnsafe() {
        brownNoiseLastOutput = 0.0
        pinkNoiseGenerators = Array(repeating: 0.0, count: 16)
        pinkNoiseCounter = 0
    }

    private func generateSampleUnsafe(for type: NoiseType) -> Float {
        switch type {
        case .white:
            return generateWhiteNoiseUnsafe()
        case .brown:
            return generateBrownNoiseUnsafe()
        case .pink:
            return generatePinkNoiseUnsafe()
        }
    }

    // MARK: - Noise Generation Algorithms (must be called with lock held)

    /// White noise: Random values uniformly distributed
    private func generateWhiteNoiseUnsafe() -> Float {
        Float.random(in: -1...1)
    }

    /// Brown noise: Integrated white noise (random walk)
    private func generateBrownNoiseUnsafe() -> Float {
        let white = Float.random(in: -1...1)
        brownNoiseLastOutput += white * 0.02

        // Clamp to prevent drift
        brownNoiseLastOutput = max(-1, min(1, brownNoiseLastOutput))

        // Scale for better volume
        return brownNoiseLastOutput * 3.5
    }

    /// Pink noise: Voss-McCartney algorithm
    /// Uses multiple random generators updated at different rates
    private func generatePinkNoiseUnsafe() -> Float {
        pinkNoiseCounter = pinkNoiseCounter &+ 1

        // Find trailing zeros to determine which generators to update
        var k = pinkNoiseCounter
        var numZeros = 0
        while k != 0 && (k & 1) == 0 {
            numZeros += 1
            k >>= 1
        }

        // Update the appropriate generator
        if numZeros < pinkNoiseGenerators.count {
            pinkNoiseGenerators[numZeros] = Float.random(in: -1...1)
        }

        // Sum all generators
        var sum: Float = 0
        for generator in pinkNoiseGenerators {
            sum += generator
        }

        // Normalize
        return sum / Float(pinkNoiseGenerators.count)
    }
}
