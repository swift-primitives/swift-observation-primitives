// Observation.Property.swift

extension Observation {
    /// Namespace for property-related types within the observation domain.
    ///
    /// Hosts the typed property identifier ``Observation/Property/ID`` —
    /// a `Tagged`-backed `UInt32` discriminated by `Observation.Property`
    /// itself (the namespace is the Tag).
    ///
    /// The namespace exists so that the property identifier can be
    /// nested as `Observation.Property.ID` per `[API-NAME-001]`'s
    /// Nest.Name discipline, replacing the earlier compound-name
    /// `PropertyID` that violated `[API-NAME-001]`.
    public enum Property {}
}
