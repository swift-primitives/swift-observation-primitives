// Observable.swift
// Top-level adjective typealias for `Observation.\`Protocol\``, providing
// the natural English conformance reading.

/// The natural English conformance reading of the canonical capability
/// protocol ``Observation/Protocol``.
///
/// `Observable` and `Observation.\`Protocol\`` resolve to the same
/// protocol declaration. Use the spelling that reads best at the call
/// site:
///
/// - `extension Foo: Observable {}` — conformance sites
/// - `func process<T: Observable>(_ t: T)` — generic constraints
/// - `func track(_ x: borrowing some Observable)` — opaque-some
///   constraints
/// - `func f<T: Observation.\`Protocol\`>(_ t: T)` — library-internal,
///   namespace-anchored form
///
/// Per `[PKG-NAME-002]`, the noun-form namespace `Observation` hosts
/// the canonical capability protocol `Observation.\`Protocol\``; the
/// top-level adjective typealias preserves the gerund-style English
/// reading at conformance sites without sacrificing the namespace
/// discipline.
public typealias Observable = Observation.`Protocol`
