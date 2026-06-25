# ``Observation_Primitives``

L1 vocabulary + Mutex-protected registrar for observation — reshapes
Apple's `Observation` framework for `~Copyable` and `~Escapable` Subjects.

## Overview

Apple's `Observation` framework (`@Observable` macro / `Observable`
protocol / `ObservationRegistrar`) is class-only by macro denylist
(`'@Observable' cannot be applied to struct/enum/actor type`). The
underlying primitives can be reshaped for `~Copyable` Subjects —
the class-only restriction is a copy-on-write ambiguity argument
that's dissolved by `~Copyable`'s compile-time prohibition of copies
(see `swift-institute/Research/swift-observation-primitives-design-investigation.md`
for the full design rationale).

This L1 package is **platform-free** per [PLAT-ARCH-008c] — the
registrar's thread-safe state is protected by stdlib's
`Synchronization.Mutex<State>` (Swift 6.0+) rather than platform-
specific locks. stdlib types are not platform code; the L1 package
imports no `Darwin`/`Glibc`/`Musl`/`WinSDK` modules.

## Current surface

- ``Observation/Protocol`` — empty marker; `~Copyable, ~Escapable`-friendly
- ``Observable`` — top-level adjective typealias for ``Observation/Protocol``
- ``Observation/Property`` — property namespace
- ``Observation/Property/ID`` — typed `UInt32` wrapper via `Tagged<Property, UInt32>`,
  replaces `AnyKeyPath` keying to sidestep the `WritableKeyPath`
  Q1-only constraint per
  `swift-institute/Research/mutator-writable-keypath-interaction.md`
- ``Observation/Subscription`` — subscription namespace
- ``Observation/Subscription/ID`` — typed `UInt64` wrapper via `Tagged<Subscription, UInt64>`,
  the opaque handle vended by `subscribe(to:willSet:didSet:)` and
  consumed by `unsubscribe(_:)`
- ``Observation/Registrar`` — lock-protected `Property.ID → Subscription.ID` index;
  struct-with-class-Extent CoW shape; `Mutex<State>` from stdlib
  `Synchronization` framework

## Future direction (planned for L3 `swift-observations`)

- `withObservationTracking { ... } onChange: { ... }` — thread-local-context tracking primitive
- `@Observable` macro — generates `_$registrar` member + per-property `_modify` accessors with PropertyID identification
- `Observation.Tracking.Event` / `.Token` / `.Options` — per Apple's Advanced Observation Tracking pitch
- `Observation.Tracker` protocol — public hook for downstream consumers (UI alternatives, persistence, tooling)

## Topics

### Capability protocol

- ``Observation/Protocol``
- ``Observable``

### Property identification

- ``Observation/Property``
- ``Observation/Property/ID``

### Subscription identification

- ``Observation/Subscription``
- ``Observation/Subscription/ID``

### Registrar

- ``Observation/Registrar``

### Namespace

- ``Observation``
