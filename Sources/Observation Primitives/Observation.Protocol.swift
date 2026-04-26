// Observation.Protocol.swift

extension Observation {
    /// Marker protocol for types that participate in observation.
    ///
    /// `Observation.\`Protocol\`` carries no requirements — it is a pure
    /// marker (analogous to Apple's `Observation.Observable` declaration in
    /// `stdlib/public/Observation/Sources/Observation/Observable.swift`,
    /// which is similarly empty). The `~Copyable, ~Escapable`
    /// suppressions on the protocol declaration extend conformance
    /// admissibility to noncopyable and non-escapable types — the
    /// documented gap in Apple's framework, which is class-only by
    /// macro denylist.
    ///
    /// Use the top-level adjective typealias ``Observable`` for natural
    /// English readability at conformance sites:
    ///
    /// ```swift
    /// extension Counter: Observable {}                    // canonical
    /// extension Counter: Observation.`Protocol` {}        // equivalent
    /// ```
    ///
    /// ## Why empty
    ///
    /// Apple's framework attaches observation behavior via the
    /// `@Observable` macro, which generates a registrar member and
    /// per-property accessors that delegate to the registrar. The
    /// protocol itself stays empty so that conformers are not forced
    /// into a particular accessor shape. This package follows the
    /// same convention; the macro that generates the registrar
    /// member is a future addition — for now, conformance is
    /// hand-authored:
    ///
    /// ```swift
    /// struct Counter: ~Copyable, Observable {
    ///     private let _$registrar = Observation.Registrar()
    ///     private var _raw: Int = 0
    ///
    ///     var raw: Int {
    ///         _read {
    ///             _$registrar.access(.init(0))  // PropertyID 0 = `raw`
    ///             yield _raw
    ///         }
    ///         _modify {
    ///             _$registrar.willSet(.init(0))
    ///             yield &_raw
    ///             _$registrar.didSet(.init(0))
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// A future macro layer will generate this shape mechanically.
    public protocol `Protocol`: ~Copyable, ~Escapable {}
}
