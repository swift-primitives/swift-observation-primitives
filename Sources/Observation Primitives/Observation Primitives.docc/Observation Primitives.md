# ``Observation_Primitives``

Tier-0 primitives for observation — reshaping Apple's `Observation`
framework for `~Copyable` and `~Escapable` Subjects.

## Overview

Apple's `Observation` framework (`@Observable` macro / `Observable`
protocol / `ObservationRegistrar`) is class-only by macro denylist
(`'@Observable' cannot be applied to struct/enum/actor type`). The
underlying primitives could be reshaped for `~Copyable` Subjects —
the class-only restriction is a copy-on-write ambiguity argument
that's dissolved by `~Copyable`'s compile-time prohibition of copies
(see `swift-institute/Research/swift-observation-primitives-design-investigation.md`
for the full design rationale).

This package provides the reshape: a marker capability protocol
``Observation/Protocol`` (with top-level adjective typealias
``Observable``), a ``Observation/Registrar`` witness type, and a typed
``Observation/Property/ID``. The current surface is sufficient for
hand-authored Subject conformances to opt into observation with
cross-thread-safe willSet/didSet notifications.

## Current surface

- ``Observation/Protocol`` — empty marker; `~Copyable, ~Escapable`-friendly
- ``Observable`` — top-level adjective typealias for ``Observation/Protocol``
- ``Observation/Registrar`` — lock-protected (PropertyID → observers) index, struct-with-class-Extent CoW shape
- ``Observation/Property/ID`` — typed `UInt32` wrapper, replaces `AnyKeyPath` keying

## Future direction

- `withObservationTracking { ... } onChange: { ... }` — thread-local-context tracking primitive
- `@Observable` macro — generates `_$registrar` member + per-property `_modify` accessors with PropertyID identification
- `Observation.Tracking.Event` / `.Token` / `.Options` — per Apple's Advanced Observation Tracking pitch
- `Observation.Tracker` protocol — public hook for downstream consumers (UI alternatives, persistence, tooling)

## Topics

### Capability protocol

- ``Observation/Protocol``
- ``Observable``

### Witness types

- ``Observation/Registrar``
- ``Observation/Property/ID``

### Namespace

- ``Observation``
