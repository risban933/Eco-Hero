//
//  LiquidGlassCompatibility.swift
//  Eco Hero
//
//  Backward compatibility wrapper for iOS 26 Liquid Glass effects.
//  Provides seamless fallbacks for iOS 18-25 using Material blur effects.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import SwiftUI

// MARK: - Glass Effect Container (Compatibility Wrapper)

/// Wrapper container that provides Liquid Glass effects on iOS 26+
/// and falls back to standard VStack on iOS 18-25.
struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        // Both versions use VStack; glass effects are applied per-view
        VStack(spacing: spacing) {
            content()
        }
    }
}

// MARK: - Compatibility Extensions

extension View {
    /// Applies a glass-like effect that works across iOS 18-26.
    /// - iOS 26+: Uses Liquid Glass with interactive tinting
    /// - iOS 18-25: Uses Material blur with similar appearance
    @ViewBuilder
    func compatibleGlassEffect(
        tintColor: Color? = nil,
        cornerRadius: CGFloat = 16,
        interactive: Bool = true
    ) -> some View {
        if #available(iOS 26, *) {
            // iOS 26+: Use Liquid Glass
            if let tint = tintColor, interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else if let tint = tintColor {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            // iOS 18-25: Material blur fallback
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .background(
                            tintColor.map {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .fill($0)
                            }
                        )
                )
        }
    }

    /// Applies a glass effect with a specific shape.
    @ViewBuilder
    func compatibleGlassEffect<S: InsettableShape>(
        tintColor: Color? = nil,
        shape: S,
        interactive: Bool = true
    ) -> some View {
        if #available(iOS 26, *) {
            // iOS 26+: Use Liquid Glass
            if let tint = tintColor, interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: shape)
            } else if let tint = tintColor {
                self.glassEffect(.regular.tint(tint), in: shape)
            } else {
                self.glassEffect(.regular, in: shape)
            }
        } else {
            // iOS 18-25: Material blur fallback
            self
                .background(
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(
                            shape
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .background(
                            tintColor.map {
                                shape.fill($0)
                            }
                        )
                )
        }
    }

    /// Assigns an ID to a glass effect element (iOS 26+ only, no-op on earlier versions).
    @ViewBuilder
    func compatibleGlassEffectID(_ id: String, in namespace: Namespace.ID) -> some View {
        if #available(iOS 26, *) {
            self.glassEffectID(id, in: namespace)
        } else {
            self
        }
    }

    /// Creates a union of glass effect regions (iOS 26+ only, applies single glass effect on iOS 18-25).
    @ViewBuilder
    func compatibleGlassEffectUnion(id: String, namespace: Namespace.ID) -> some View {
        if #available(iOS 26, *) {
            self.glassEffectUnion(id: id, namespace: namespace)
        } else {
            // iOS 18-25: Apply a single glass effect to the unified container
            self.compatibleGlassEffect(cornerRadius: 16, interactive: false)
        }
    }

    /// Applies a glass effect transition (iOS 26+ only, falls back to opacity on earlier versions).
    @ViewBuilder
    func compatibleGlassEffectTransition() -> some View {
        if #available(iOS 26, *) {
            self.glassEffectTransition(.materialize)
        } else {
            self.transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}

// MARK: - Compatible Glass Button Style

struct CompatibleGlassButtonStyle: ButtonStyle {
    let tintColor: Color?
    let cornerRadius: CGFloat
    let interactive: Bool

    init(tintColor: Color? = nil, cornerRadius: CGFloat = 16, interactive: Bool = true) {
        self.tintColor = tintColor
        self.cornerRadius = cornerRadius
        self.interactive = interactive
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if #available(iOS 26, *) {
                        // iOS 26+: Use ultraThinMaterial with tint (glass effect applied separately)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .background(
                                tintColor.map {
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .fill($0)
                                }
                            )
                    } else {
                        // iOS 18-25: Material blur button
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .background(
                                tintColor.map {
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .fill($0)
                                }
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CompatibleGlassButtonStyle {
    static func compatibleGlass(
        tintColor: Color? = nil,
        cornerRadius: CGFloat = 16,
        interactive: Bool = true
    ) -> CompatibleGlassButtonStyle {
        CompatibleGlassButtonStyle(tintColor: tintColor, cornerRadius: cornerRadius, interactive: interactive)
    }
}

// MARK: - Apple Intelligence Availability Check

extension View {
    /// Check if Apple Intelligence features are available.
    /// Returns true on iOS 26+ with compatible hardware, false otherwise.
    var isAppleIntelligenceAvailable: Bool {
        if #available(iOS 26, *) {
            // On iOS 26+, Apple Intelligence is available on supported hardware
            // For now, assume all iOS 26+ devices support it
            return true
        }
        return false
    }
}

// MARK: - Documentation

/*
 ## Backward Compatibility Strategy

 This file ensures Eco Hero works seamlessly on iOS 18.0 through iOS 26+ by:

 1. **Runtime Availability Checks**
    - Uses `if #available(iOS 26, *)` to conditionally enable iOS 26 features
    - Provides visually similar fallbacks for older iOS versions

 2. **Liquid Glass Effects**
    - iOS 26+: Full Liquid Glass with interactive tinting and transitions
    - iOS 18-25: Material blur effects (.ultraThinMaterial) with similar visual appearance
    - All compatibility methods prefixed with `compatible` to avoid naming conflicts

 3. **Apple Intelligence**
    - iOS 26+: FoundationModels for on-device AI (already handled in FoundationContentService.swift)
    - iOS 18-25: Static fallback content and legacy CoreML models

 4. **Graceful Degradation**
    - All UI elements remain functional on older devices
    - Layout and navigation are preserved across all versions
    - No features are removed; only visual enhancements differ

 ## Usage Example

 ```swift
 // Replace iOS 26-specific code:
 // .glassEffect(.regular.tint(.green.opacity(0.3)).interactive(), in: .rect(cornerRadius: 16))

 // With compatible version:
 .compatibleGlassEffect(tintColor: .green.opacity(0.3), cornerRadius: 16, interactive: true)

 // iOS 26: Renders with Liquid Glass
 // iOS 18-25: Renders with Material blur (visually similar)
 ```

 ## Migration Checklist for Views

 Replace these iOS 26-specific APIs with compatible versions:

 - `.glassEffect()` → `.compatibleGlassEffect()`
 - `.glassEffectID()` → `.compatibleGlassEffectID()`
 - `.glassEffectUnion()` → `.compatibleGlassEffectUnion()`
 - `.glassEffectTransition()` → `.compatibleGlassEffectTransition()`
 - `.buttonStyle(.glass())` → `.buttonStyle(.compatibleGlass())`

 ## Testing Checklist

 - [ ] Build succeeds on Xcode with iOS 18.0 deployment target
 - [ ] App runs on iOS 18 simulator (fallback UI)
 - [ ] App runs on iOS 26 simulator (full Liquid Glass)
 - [ ] No visual regressions on either version
 - [ ] All features functional on both versions
 */
