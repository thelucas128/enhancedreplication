<p align="center">
  <a href="https://github.com/nodeal-framework">
    <img src="https://raw.githubusercontent.com/nodeal-framework/.github/main/assets/nodeal.svg" width="200" alt="Nodeal Framework" />
  </a>
</p>

<h1 align="center">Nodeal Enhanced Replication</h1>

<p align="center">
  <strong>Custom character replication for Roblox</strong> | Built for <a href="https://github.com/nodeal-framework">Nodeal Framework</a> | <a href="https://www.nodeal.dev/packages/enhancedrep">enhancedrep v1.1</a>
</p>

---

## Stats

| Metric | Value |
|--------|-------|
| ECS components | 6 (Position, Velocity, Rotation, Timestamp, Owner, JecsCharacter) |
| NetworkService networks | 2 (EntitySync, Loaded) |
| Capsule dimensions | 2.63 x 5.64 x 2.63 studs |
| Capsule mesh | `73706483794360` |
| Client sync cadence | Every `PostSimulation` |
| Server drive cadence | Every `PreSimulation` |

---

## What it does

Replaces Roblox's default character replication for lower latency.

### How it works

- **Client:** streams `HumanoidRootPart` CFrame + velocity every `PostSimulation` via `EntitySync` (buffered `CFrame`/`Velocity`), destroys the root `WeldConstraint`
- **Server:** tracks each player as a [jecs](https://github.com/Ukendio/jecs) ECS entity (`Position` / `Velocity` / `Rotation` / `Timestamp` / `Owner`), clones the Capsule into the character as `CapsuleReplication`, and drives it in `PreSimulation`
- **Handshake:** `Loaded` event gates replication until the client signals ready

The Capsule overwrites Roblox's default - instance and code are split below.

---

## Install

**Nodeal** - package ID `enhancedrep`.

- **Full drag-drop:** `assets/enhancedrep/enhancedReplication.rbxmx`
- **Or rebuild the hierarchy:** ModuleScript `enhancedReplication` with children `jecs` (`src/enhancedrep/jecs.luau`) + `Capsule` (`assets/enhancedrep/Capsule.rbxmx`), source from `src/enhancedrep/init.luau`

Hierarchy must stay `enhancedReplication` with children `jecs` + `Capsule` - code does `require(script.jecs)` and `script.Capsule:Clone()`.

Capsule `MeshPart`: mesh `73706483794360`, 2.63 x 5.64 x 2.63, Transparency 0.5, Anchored, `CanCollide` off, Massless.

---

## Files

| File | Purpose |
|------|---------|
| `src/enhancedrep/init.luau` | Main module (`Client` / `Server` / `Init`, branches on `RunService:IsClient()`) |
| `src/enhancedrep/jecs.luau` | ECS dependency |
| `assets/enhancedrep/Capsule.rbxmx` | Capsule instance only |
| `assets/enhancedrep/enhancedReplication.rbxmx` | Complete original file |

---

## License

MIT - see source files for original code.
