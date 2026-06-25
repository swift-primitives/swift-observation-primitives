// Observation.Subscription.ID.swift

public import Tagged_Primitives

extension Observation.Subscription {
    /// A typed identifier for a single subscription to an
    /// ``Observation/Registrar``, backed by
    /// `Tagged<Observation.Subscription, UInt64>`.
    ///
    /// Each call to
    /// ``Observation/Registrar/subscribe(to:willSet:didSet:)`` allocates
    /// a fresh ID from the registrar's monotonic counter and returns
    /// it; the caller must retain the ID to later
    /// ``Observation/Registrar/unsubscribe(_:)``.
    ///
    /// The `Tagged` Tag is `Observation.Subscription` itself: the
    /// namespace is also the discriminator, so `Subscription.ID`
    /// cannot be confused at the type level with any other
    /// `Tagged<_, UInt64>` instantiation — including
    /// ``Observation/Property/ID`` (which is `Tagged<Property, UInt32>`,
    /// distinguished both by Tag and RawValue width).
    ///
    /// `ID` is opaque on the type-system side and meaningful only in
    /// the scope of the registrar that vended it: two registrars
    /// reusing the integer value `0` for their respective first
    /// subscriptions are not collateral collisions because each ID is
    /// always paired with the registrar instance that owns its
    /// observer table.
    ///
    /// The `UInt64` width matches Apple's `ObservationRegistrar.Id`
    /// (per the Advanced Observation Tracking pitch) and admits ~1.8e19
    /// subscriptions over the registrar's lifetime — far beyond any
    /// practical exhaustion path under monotonic allocation.
    public typealias ID = Tagged<Observation.Subscription, UInt64>
}

// MARK: - Convenience initializer

extension Tagged where Tag == Observation.Subscription, Underlying == UInt64 {
    /// Creates an ``Observation/Subscription/ID`` from its raw integer
    /// value.
    ///
    /// The `Tagged` design reserves the unlabeled-init path for domain-
    /// validated construction. For subscription IDs there is no
    /// validation (any `UInt64` value is a valid subscription ID
    /// within its registrar's scope), so this convenience init wraps
    /// the unchecked Tagged constructor without ceremony.
    @inlinable
    public init(_ rawValue: UInt64) {
        self.init(_unchecked: rawValue)
    }
}
