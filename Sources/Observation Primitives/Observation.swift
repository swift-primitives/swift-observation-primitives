// Observation.swift
// The Observation namespace.

/// The observation namespace.
///
/// Hosts the marker protocol ``Observation/Protocol`` (with top-level
/// adjective typealias ``Observable``), the typed property identifier
/// ``Observation/Property/ID``, and the lock-protected witness
/// ``Observation/Registrar`` for types that opt into observation.
/// Mirrors the public shape of Apple's `Observation` framework while
/// extending coverage to `~Copyable` and `~Escapable` Subjects — the
/// documented gap in Apple's class-only `@Observable` macro.
///
/// Per [PLAT-ARCH-008c], this L1 package is platform-free. The
/// Registrar's thread-safe state is protected by stdlib's
/// `Synchronization.Mutex<State>` rather than platform-specific
/// locks — stdlib types are universally available without platform
/// imports.
///
/// ## Current surface (L1 vocabulary + sync via stdlib `Synchronization`)
///
/// - ``Observation/Protocol`` — empty marker protocol; `~Copyable, ~Escapable`-friendly
/// - ``Observable`` — top-level adjective typealias for ``Observation/Protocol``
/// - ``Observation/Property`` — property namespace
/// - ``Observation/Property/ID`` — typed property identifier (`Tagged<Property, UInt32>`)
/// - ``Observation/Subscription`` — subscription namespace
/// - ``Observation/Subscription/ID`` — typed subscription identifier (`Tagged<Subscription, UInt64>`)
/// - ``Observation/Registrar`` — lock-protected `Property.ID → Subscription.ID` index;
///   `Mutex<State>` from stdlib `Synchronization`
///
/// ## Future direction (planned at L3 `swift-observations`)
///
/// - `withObservationTracking { ... } onChange: { ... }` — thread-local-context tracking primitive
/// - `@Observable` macro — generates `_$registrar` member + per-property `_modify` accessors
/// - `Observation.Tracking.Event` / `.Token` / `.Options` — per Apple's Advanced Observation Tracking pitch
/// - `Observation.Tracker` protocol — public hook for downstream consumers (UI alternatives, persistence, tooling)
///
/// See `swift-institute/Research/swift-observation-primitives-design-investigation.md`
/// for the design rationale and Apple-Observation deep-dive.
public enum Observation {}
