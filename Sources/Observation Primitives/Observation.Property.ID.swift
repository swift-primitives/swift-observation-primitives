// Observation.Property.ID.swift

public import Tagged_Primitives

extension Observation.Property {
    /// A typed identifier for a stored property of an ``Observable``
    /// Subject, backed by `Tagged<Observation.Property, UInt32>`.
    ///
    /// Each Subject's stored properties receive a unique
    /// `Observation.Property.ID` at macro-expansion time (or at hand-
    /// authored conformance time today, before the macro ships). The
    /// registrar's index is keyed by `ID` rather than by `AnyKeyPath`
    /// to sidestep the `WritableKeyPath` Q1-only constraint that
    /// propagates `Root: Copyable & Escapable` through any keypath-
    /// keyed accessor (see
    /// `swift-institute/Research/mutator-writable-keypath-interaction.md`).
    ///
    /// The `Tagged` Tag is `Observation.Property` itself: the
    /// namespace is also the discriminator, so `Property.ID` cannot
    /// be confused with any other `Tagged<_, UInt32>` instantiation
    /// at the type level.
    ///
    /// `ID` is opaque on the type-system side: two Subjects reusing
    /// the integer value `0` for their respective first stored
    /// properties are not collateral collisions, because the `ID` is
    /// always paired with a specific ``Observation/Registrar``
    /// instance (one per Subject). The `ID` is meaningful only in
    /// the scope of its owning Registrar.
    ///
    /// The `UInt32` width is the stdlib-precedent choice for stable,
    /// small-integer identifiers and admits 4 billion properties per
    /// Subject — far beyond any practical Subject shape.
    public typealias ID = Tagged<Observation.Property, UInt32>
}

// MARK: - Convenience initializer

extension Tagged where Tag == Observation.Property, RawValue == UInt32 {
    /// Creates an `Observation.Property.ID` from its raw integer value.
    ///
    /// The `Tagged` design reserves the unlabeled-init path for domain-
    /// validated construction. For property IDs there is no validation
    /// (any `UInt32` value is a valid property ID within its registrar's
    /// scope), so this convenience init wraps the unchecked Tagged
    /// constructor without ceremony.
    @inlinable
    public init(_ rawValue: UInt32) {
        self.init(__unchecked: (), rawValue)
    }
}
