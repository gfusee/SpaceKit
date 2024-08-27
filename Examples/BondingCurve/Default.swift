// A protocol to imitate the Rust coding style
protocol Default {
    // An init is better rather than a static function because the Swift Embedded can complain when generics are involved
    init(default: ())
}
