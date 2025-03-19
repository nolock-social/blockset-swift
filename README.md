# blockset-swift

## Commit Format

TypeScript:

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
