// Observation.Registrar.swift

public import Tagged_Primitives

extension Observation {

    /// Lock-protected registrar of (PropertyID -> observer-IDs)
    /// bindings. The struct holds a heap-allocated extent (a class)
    /// so that copies share state — but copies of the Subject that
    /// owns the registrar are themselves prevented when the Subject
    /// is `~Copyable`, sidestepping the copy-on-write ambiguity that
    /// motivated Apple's class-only restriction (per SE-0395 second-
    /// review thread #119).
    ///
    /// ## Internal shape
    ///
    /// Mirrors Apple's `ObservationRegistrar` design:
    /// - struct → heap-allocated ``Observation/Registrar/Extent`` class (CoW shape)
    /// - bidirectional index in ``Observation/Registrar/State``:
    ///   `[PropertyID: Set<observerID>]` lookups +
    ///   `[observerID: Observer]` observers
    /// - monotonic ``Observation/Registrar/Observer`` ID allocator (UInt64)
    /// - platform-specific lock primitive (`os_unfair_lock` on
    ///   Darwin, `pthread_mutex_t` on Linux, `SRWLOCK` on Windows)
    ///
    /// Replaces Apple's `(ObjectIdentifier(subject), AnyKeyPath)`
    /// keying with `PropertyID` keying — the registrar's heap-extent
    /// IS the Subject's stable identity (each Subject owns one).
    public struct Registrar: Sendable {
        let _extent: Extent

        public init() {
            self._extent = Extent()
        }
    }
}

// MARK: - Read & write notification

extension Observation.Registrar {
    /// Records a property access.
    ///
    /// Currently a no-op — no thread-local tracking context is
    /// established yet. Callers may invoke it for forward-compatibility
    /// with the future `withObservationTracking` primitive; the same
    /// call site will then register the property access with the
    /// active tracking context.
    public func access(_ propertyID: Observation.Property.ID) {
        // No-op today. Future tracking primitive will inspect the
        // thread-local tracking context and append
        // (registrar-extent, propertyID) to its access list.
        _ = propertyID
    }

    /// Notifies all observers registered for `propertyID` that a
    /// mutation is about to occur.
    public func willSet(_ propertyID: Observation.Property.ID) {
        let callbacks: [@Sendable (Observation.Property.ID) -> Void] =
            _extent.lock.withLock {
                guard let observerIDs = _extent.state.lookups[propertyID] else {
                    return []
                }
                return observerIDs.compactMap { id in
                    _extent.state.observers[id]?.willSet
                }
            }
        for callback in callbacks {
            callback(propertyID)
        }
    }

    /// Notifies all observers registered for `propertyID` that a
    /// mutation has just occurred.
    public func didSet(_ propertyID: Observation.Property.ID) {
        let callbacks: [@Sendable (Observation.Property.ID) -> Void] =
            _extent.lock.withLock {
                guard let observerIDs = _extent.state.lookups[propertyID] else {
                    return []
                }
                return observerIDs.compactMap { id in
                    _extent.state.observers[id]?.didSet
                }
            }
        for callback in callbacks {
            callback(propertyID)
        }
    }

    /// Wraps a mutation in willSet/didSet bookkeeping.
    ///
    /// - Parameters:
    ///   - propertyID: The property being mutated.
    ///   - body: The mutation closure. Throws of type `E` are
    ///     propagated; in either path, `didSet` fires (matching
    ///     Apple's `ObservationRegistrar.withMutation` semantics).
    public func withMutation<R: ~Copyable, E: Error>(
        of propertyID: Observation.Property.ID,
        _ body: () throws(E) -> R
    ) throws(E) -> R {
        willSet(propertyID)
        defer { didSet(propertyID) }
        return try body()
    }
}

// MARK: - Subscription

extension Observation.Registrar {
    /// Registers an observer for the given properties.
    ///
    /// Returns an opaque observer ID that the caller MUST retain to
    /// unregister later. Currently the raw `UInt64` ID is returned;
    /// a future addition will replace this with a `~Copyable`
    /// `Token` that auto-unregisters on `consume`.
    ///
    /// - Parameters:
    ///   - properties: The set of PropertyIDs to watch.
    ///   - willSet: Optional callback for pre-mutation notification.
    ///   - didSet: Optional callback for post-mutation notification.
    /// - Returns: Opaque observer ID for later unregistration.
    public func subscribe(
        to properties: Set<Observation.Property.ID>,
        willSet: (@Sendable (Observation.Property.ID) -> Void)? = nil,
        didSet: (@Sendable (Observation.Property.ID) -> Void)? = nil
    ) -> UInt64 {
        _extent.lock.withLock {
            let id = _extent.state.nextObserverID
            _extent.state.nextObserverID &+= 1

            _extent.state.observers[id] = Observer(
                properties: properties,
                willSet: willSet,
                didSet: didSet
            )

            for propertyID in properties {
                _extent.state.lookups[propertyID, default: []].insert(id)
            }

            return id
        }
    }

    /// Unregisters the observer with the given ID.
    public func unsubscribe(_ observerID: UInt64) {
        _extent.lock.withLock {
            guard let observer = _extent.state.observers.removeValue(forKey: observerID) else {
                return
            }
            for propertyID in observer.properties {
                _extent.state.lookups[propertyID]?.remove(observerID)
                if _extent.state.lookups[propertyID]?.isEmpty == true {
                    _extent.state.lookups[propertyID] = nil
                }
            }
        }
    }
}
