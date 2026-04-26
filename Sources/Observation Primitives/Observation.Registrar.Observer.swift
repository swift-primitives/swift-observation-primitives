// Observation.Registrar.Observer.swift

public import Tagged_Primitives

extension Observation.Registrar {
    /// A single registered observer's metadata: which properties it
    /// watches and the willSet/didSet callbacks to fire.
    ///
    /// Copyable because: stored as the Value type of a stdlib
    /// `Dictionary<UInt64, Observer>` in `State`, which requires
    /// Copyable. Copying an `Observer` instance is fine — it copies
    /// the Set + the two optional `@Sendable` closure references — and
    /// happens only inside the registrar's lock-protected scope.
    struct Observer {
        /// Properties this observer is watching.
        var properties: Set<Observation.Property.ID>

        /// willSet callback (fires before mutation).
        var willSet: (@Sendable (Observation.Property.ID) -> Void)?

        /// didSet callback (fires after mutation).
        var didSet: (@Sendable (Observation.Property.ID) -> Void)?

        init(
            properties: Set<Observation.Property.ID>,
            willSet: (@Sendable (Observation.Property.ID) -> Void)?,
            didSet: (@Sendable (Observation.Property.ID) -> Void)?
        ) {
            self.properties = properties
            self.willSet = willSet
            self.didSet = didSet
        }
    }
}
