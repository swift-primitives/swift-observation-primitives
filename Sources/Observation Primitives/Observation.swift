// Observation.swift
// The Observation namespace.

/// The observation namespace.
///
/// Hosts the marker protocol ``Observation/Protocol`` (with top-level
/// adjective typealias ``Observable``) and the witness type
/// ``Observation/Registrar`` for types that opt into observation.
/// Mirrors the public shape of Apple's
/// `Observation` framework while extending coverage to `~Copyable`
/// and `~Escapable` Subjects — the documented gap in Apple's
/// class-only `@Observable` macro.
///
/// ## Current surface
///
/// - ``Observation/Protocol`` — empty marker protocol; conformance
///   is `~Copyable, ~Escapable`-friendly.
/// - ``Observable`` — top-level adjective typealias for
///   ``Observation/Protocol`` (English-natural conformance reading).
/// - ``Observation/Registrar`` — lock-protected witness keyed by
///   ``Observation/Property/ID``.
/// - ``Observation/Property/ID`` — typed `UInt32` wrapper for property
///   identification (replaces `AnyKeyPath` to sidestep the
///   `WritableKeyPath` Q1-only constraint per
///   `swift-institute/Research/mutator-writable-keypath-interaction.md`).
///
/// ## Future direction
///
/// - `withObservationTracking` (thread-local context) — needs C shim
///   or thread-local primitive.
/// - `@Observable` macro — generates `_$registrar` + per-property
///   `_modify` accessors with `PropertyID` identification.
/// - `Observation.Tracking.Event` / `.Token` / `.Options` — per
///   Apple's Advanced Observation Tracking pitch shape.
/// - `Observation.Tracker` protocol — public hook for downstream
///   consumers (SwiftUI-alternatives, persistence layers, etc.).
///
/// See `swift-institute/Research/swift-observation-primitives-design-investigation.md`
/// for the design rationale and Apple-Observation deep-dive.
public enum Observation {}
