// Observation.Registrar.State.swift

import Tagged_Primitives

extension Observation.Registrar {
    /// The lock-protected mutable state of the registrar.
    ///
    /// Holds the bidirectional observer index (PropertyID → observer IDs
    /// + observer ID → metadata) plus the monotonic observer-ID
    /// allocator. Accessed only through the owning
    /// `Ownership.Immutable<Mutex<State>>` extent's `Mutex<State>`.
    ///
    /// Copyable because: this struct is the protected `Value` of a
    /// stdlib `Synchronization.Mutex<State>`; the Mutex's `withLock`
    /// hands out `inout State` references, which Swift's exclusivity
    /// model already enforces. Its sub-fields (`Dictionary`, `UInt64`)
    /// are themselves Copyable and stdlib-required to be so for
    /// storage in `Dictionary` values.
    struct State {
        /// Index from PropertyID to the set of subscription IDs
        /// watching that property.
        var lookups: [Observation.Property.ID: Set<Observation.Subscription.ID>] = [:]

        /// Index from subscription ID to the observer's metadata
        /// (callbacks + watched property set).
        var observers: [Observation.Subscription.ID: Observer] = [:]

        /// Monotonic subscription-ID allocator.
        var nextSubscriptionID: UInt64 = 0
    }
}
