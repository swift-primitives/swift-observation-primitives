// Observation.Registrar.State.swift

public import Tagged_Primitives

extension Observation.Registrar {
    /// The lock-protected mutable state of an `Extent`.
    ///
    /// Holds the bidirectional observer index (PropertyID → observer IDs
    /// + observer ID → metadata) plus the monotonic observer-ID
    /// allocator. Accessed only through the owning `Extent`'s lock.
    ///
    /// Copyable because: this struct is a stored property of the
    /// reference-typed `Extent` and never escapes the lock-protected
    /// scope. Its sub-fields (`Dictionary`, `UInt64`) are themselves
    /// Copyable and stdlib-required to be so for storage in
    /// `Dictionary` values.
    struct State {
        /// Index from PropertyID to the set of observer IDs watching
        /// that property.
        var lookups: [Observation.Property.ID: Set<UInt64>] = [:]

        /// Index from observer ID to the observer's metadata
        /// (callbacks + watched property set).
        var observers: [UInt64: Observer] = [:]

        /// Monotonic observer-ID allocator.
        var nextObserverID: UInt64 = 0
    }
}
