import Foundation
import ServiceManagement
import Observation

enum CycleDuration: Int, CaseIterable, Identifiable {
    case infinite = 0
    case thirty = 30
    case forty = 40
    case sixty = 60

    var id: Int { rawValue }
    var displayName: String {
        rawValue == 0 ? "∞" : "\(rawValue)"
    }
    var seconds: TimeInterval? {
        rawValue == 0 ? nil : TimeInterval(rawValue * 60)
    }
}

enum RestDuration: Int, CaseIterable, Identifiable {
    case none = 0
    case five = 5
    case ten = 10
    case fifteen = 15

    var id: Int { rawValue }
    var displayName: String {
        rawValue == 0 ? "N/A" : "\(rawValue)"
    }
    var seconds: TimeInterval? {
        rawValue == 0 ? nil : TimeInterval(rawValue * 60)
    }
}

@Observable
final class AppState {
    private let noiseEngine = NoiseEngine()

    private let activeNoiseKey = "activeNoise"
    private let volumeKey = "volume"
    private let launchAtLoginKey = "launchAtLogin"
    private let cycleDurationKey = "cycleDuration"
    private let restDurationKey = "restDuration"

    var activeNoise: NoiseType? {
        didSet {
            if let noise = activeNoise {
                noiseEngine.play(type: noise)
                startCycleIfNeeded()
            } else {
                noiseEngine.stop()
                stopTimers()
            }
            saveState()
        }
    }

    var volume: Double = 0.7 {
        didSet {
            noiseEngine.setVolume(Float(volume))
            saveState()
        }
    }

    var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
            saveState()
        }
    }

    var cycleDuration: CycleDuration = .infinite {
        didSet {
            saveState()
            if isPlaying && !isResting {
                startCycleIfNeeded()
            }
        }
    }

    var restDuration: RestDuration = .none {
        didSet {
            saveState()
        }
    }

    var isPlaying: Bool {
        activeNoise != nil
    }

    // Timer state
    private var cycleTimer: Timer?
    private var restTimer: Timer?
    var isResting: Bool = false
    var timeRemaining: TimeInterval = 0
    private var displayTimer: Timer?

    var hasCycleTimer: Bool {
        cycleDuration.seconds != nil
    }

    init() {
        loadState()
        noiseEngine.setVolume(Float(volume))

        // If we had an active noise saved, start playing it
        if let noise = activeNoise {
            noiseEngine.play(type: noise)
            startCycleIfNeeded()
        }
    }

    func toggleNoise(_ type: NoiseType) {
        if activeNoise == type {
            activeNoise = nil
        } else {
            activeNoise = type
        }
    }

    // MARK: - Timer Management

    private func startCycleIfNeeded() {
        stopTimers()
        isResting = false

        guard let duration = cycleDuration.seconds else {
            // Infinite mode - no timer
            return
        }

        timeRemaining = duration
        startDisplayTimer()

        cycleTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.startRest()
        }
    }

    private func startRest() {
        guard let restSeconds = restDuration.seconds else {
            // No rest - immediately start next cycle
            startCycleIfNeeded()
            return
        }

        isResting = true
        noiseEngine.stop()
        timeRemaining = restSeconds

        restTimer = Timer.scheduledTimer(withTimeInterval: restSeconds, repeats: false) { [weak self] _ in
            self?.endRest()
        }
    }

    private func endRest() {
        isResting = false
        if let noise = activeNoise {
            noiseEngine.play(type: noise)
            startCycleIfNeeded()
        }
    }

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        }
    }

    private func stopTimers() {
        cycleTimer?.invalidate()
        cycleTimer = nil
        restTimer?.invalidate()
        restTimer = nil
        displayTimer?.invalidate()
        displayTimer = nil
        timeRemaining = 0
        isResting = false
    }

    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Persistence

    private func loadState() {
        let defaults = UserDefaults.standard

        if let noiseRaw = defaults.string(forKey: activeNoiseKey),
           let noise = NoiseType(rawValue: noiseRaw) {
            activeNoise = noise
        }

        if defaults.object(forKey: volumeKey) != nil {
            volume = defaults.double(forKey: volumeKey)
        }

        launchAtLogin = defaults.bool(forKey: launchAtLoginKey)

        if let cycleRaw = defaults.object(forKey: cycleDurationKey) as? Int,
           let cycle = CycleDuration(rawValue: cycleRaw) {
            cycleDuration = cycle
        }

        if let restRaw = defaults.object(forKey: restDurationKey) as? Int,
           let rest = RestDuration(rawValue: restRaw) {
            restDuration = rest
        }
    }

    private func saveState() {
        let defaults = UserDefaults.standard

        if let noise = activeNoise {
            defaults.set(noise.rawValue, forKey: activeNoiseKey)
        } else {
            defaults.removeObject(forKey: activeNoiseKey)
        }

        defaults.set(volume, forKey: volumeKey)
        defaults.set(launchAtLogin, forKey: launchAtLoginKey)
        defaults.set(cycleDuration.rawValue, forKey: cycleDurationKey)
        defaults.set(restDuration.rawValue, forKey: restDurationKey)
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}
