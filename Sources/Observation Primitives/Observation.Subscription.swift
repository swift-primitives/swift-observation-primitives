// Observation.Subscription.swift

extension Observation {
    /// The subscription namespace.
    ///
    /// Hosts the typed subscription identifier
    /// ``Observation/Subscription/ID`` returned by
    /// ``Observation/Registrar/subscribe(to:willSet:didSet:)`` and
    /// consumed by ``Observation/Registrar/unsubscribe(_:)``. Each
    /// subscription names one observer's binding to a set of
    /// ``Observation/Property/ID``s within a single
    /// ``Observation/Registrar`` extent.
    ///
    /// ## Future direction (planned at L3 `swift-observations`)
    ///
    /// A `Subscription.Token` (`~Copyable`, RAII) will accompany the
    /// ID to auto-unregister on `consume` — eliminating the
    /// caller-must-retain contract that the bare `ID` carries today.
    public enum Subscription {}
}
