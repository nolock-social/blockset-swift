# blockset-swift

## Commit Format

TypeSceript:

```ts
type Commit = {
    parent: string[]
    blob?: string
}
```

Swift:

```swift
struct Commit: Codable {
    var parent: [String]
    var blob: String?
}
```
