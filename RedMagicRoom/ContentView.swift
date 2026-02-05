import SwiftUI

struct ContentView: View {
    @Bindable var state: AppState

    var body: some View {
        VStack(spacing: 12) {
            // Title
            Text("Red Magic Room")
                .font(.headline)
                .padding(.top, 4)

            // Noise type segmented control
            HStack(spacing: 8) {
                ForEach(NoiseType.allCases) { type in
                    NoiseButton(
                        type: type,
                        isActive: state.activeNoise == type,
                        action: { state.toggleNoise(type) }
                    )
                }
            }

            // Volume slider
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)

                Slider(value: $state.volume, in: 0...1)

                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Divider()

            // Cycle duration
            HStack {
                Text("Focus")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .leading)
                Picker("", selection: $state.cycleDuration) {
                    ForEach(CycleDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Rest duration
            HStack {
                Text("Rest")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .leading)
                Picker("", selection: $state.restDuration) {
                    ForEach(RestDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Timer display (only when cycle timer is active)
            if state.isPlaying && state.hasCycleTimer && state.timeRemaining > 0 {
                HStack {
                    Image(systemName: state.isResting ? "cup.and.saucer.fill" : "brain.head.profile")
                        .foregroundColor(state.isResting ? .orange : .green)
                    Text(state.isResting ? "Rest" : "Focus")
                        .font(.caption)
                    Spacer()
                    Text(state.formattedTimeRemaining)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }

            Divider()

            // Launch at Login toggle
            Toggle("Launch at Login", isOn: $state.launchAtLogin)
                .toggleStyle(.checkbox)

            Divider()

            // Quit button
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
        }
        .padding()
        .frame(width: 240)
    }
}

struct NoiseButton: View {
    let type: NoiseType
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.displayName)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isActive ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isActive ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
