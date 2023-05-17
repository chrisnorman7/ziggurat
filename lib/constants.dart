/// The signature for task functions.
typedef TaskFunction = void Function();

/// The type of a function which is called when a value changes.
typedef ValueChanged<T> = void Function(T value);
