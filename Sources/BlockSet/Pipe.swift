infix operator |> : AdditionPrecedence

func |> <A, B>(value: A, transform: (A) -> B) -> B {
    transform(value)
}
