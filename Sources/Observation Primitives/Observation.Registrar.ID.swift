// Observation.Registrar.ID.swift

extension Observation.Registrar {
    /// Stable identity for this registrar — same value across copies
    /// of the struct (which all share the same heap-allocated
    /// `Ownership.Shared<Mutex<State>>` extent).
    ///
    /// L3 consumers (e.g., a tracking primitive that records property
    /// accesses across a body closure) use this `id` as the
    /// deduplication key for "the same Subject's registrar" — two
    /// `Registrar` struct values with the same `id` are aliases of
    /// the same observer table.
    ///
    /// Returns `ObjectIdentifier(extent)`, which is unique for the
    /// lifetime of the heap extent. The Registrar struct itself does
    /// not have stable identity (struct copies are equal-by-value),
    /// but the heap extent does.
    public var id: ObjectIdentifier {
        ObjectIdentifier(_extent)
    }
}
