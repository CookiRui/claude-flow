---
name: autotest
description: "Unity AutoTest framework skill. Covers IInputProvider pattern, TestCase JSON format, TestAction/TestCondition lifecycle, and batch mode execution for automated PlayMode testing."
---

# AutoTest Framework

Skill for writing and running automated PlayMode tests using the AutoTest framework. AutoTest drives the game through JSON-defined test cases that simulate input, wait for conditions, and validate outcomes — all executable in Unity batch mode.

---

## Core Concepts

### IInputProvider Pattern

AutoTest replaces player input with a programmatic `IInputProvider` interface. All gameplay systems must read input through this abstraction, never directly from `UnityEngine.Input`.

```csharp
public interface IInputProvider
{
    Vector2 MoveInput { get; }
    bool GetActionDown(string actionName);
    bool GetAction(string actionName);
    bool GetActionUp(string actionName);
}
```

- **PlayerInputProvider** — reads from hardware input (keyboard, gamepad, touch). Used in normal gameplay.
- **AutoTestInputProvider** — reads from the AutoTest framework's action queue. Used during automated testing.

The active provider is swapped at test startup. Gameplay code never knows the difference.

---

## TestCase JSON Format

Each test case is a JSON file describing a sequence of actions and conditions:

```json
{
  "testName": "player_walk_forward_10_meters",
  "description": "Verify player can walk forward 10 meters without collision issues",
  "scene": "Assets/Scenes/TestScene.unity",
  "timeout": 30,
  "setup": {
    "playerPosition": { "x": 0, "y": 0, "z": 0 },
    "playerRotation": { "x": 0, "y": 0, "z": 0 }
  },
  "steps": [
    {
      "action": "SetMoveInput",
      "params": { "x": 0, "y": 1 },
      "duration": 5.0
    },
    {
      "condition": "PlayerPositionZ",
      "params": { "minZ": 9.0 },
      "timeout": 10.0,
      "failMessage": "Player did not reach Z=9 within timeout"
    },
    {
      "action": "SetMoveInput",
      "params": { "x": 0, "y": 0 }
    },
    {
      "condition": "PlayerIsGrounded",
      "timeout": 2.0,
      "failMessage": "Player is not grounded after stopping"
    }
  ],
  "cleanup": {
    "resetScene": true
  }
}
```

---

## TestAction Types

Actions simulate player input or trigger game events:

| Action | Params | Description |
|--------|--------|-------------|
| `SetMoveInput` | `x`, `y` (floats) | Set movement vector, held for `duration` seconds |
| `PressAction` | `actionName` (string) | Simulate a single-frame button press |
| `HoldAction` | `actionName`, `duration` | Hold a button for N seconds |
| `ReleaseAction` | `actionName` | Release a held button |
| `Wait` | `duration` | Do nothing for N seconds |
| `TeleportPlayer` | `x`, `y`, `z` | Move player to world position |
| `SpawnEntity` | `prefabPath`, `position`, `rotation` | Instantiate an entity |
| `SetTimeScale` | `scale` | Adjust `Time.timeScale` |
| `SendEvent` | `eventName`, `payload` | Publish a game event |

---

## TestCondition Types

Conditions wait until satisfied or timeout:

| Condition | Params | Description |
|-----------|--------|-------------|
| `PlayerPositionX/Y/Z` | `minX`, `maxX`, etc. | Player is within position range |
| `PlayerIsGrounded` | — | Player is on the ground |
| `EntityExists` | `entityName` or `tag` | An entity with name/tag exists in scene |
| `EntityDestroyed` | `entityName` or `tag` | Entity no longer exists |
| `UIElementVisible` | `elementPath` | A UI element is active in hierarchy |
| `UIElementText` | `elementPath`, `expectedText` | UI text matches expected value |
| `AnimationState` | `objectName`, `stateName` | Animator is in the specified state |
| `EventFired` | `eventName` | A game event was published |
| `FrameTime` | `maxMs` | Frame time is below threshold |

---

## TestAction / TestCondition Lifecycle

```
TestRunner.Start()
  ├── Load scene (from testCase.scene)
  ├── Apply setup (player position, rotation, initial state)
  ├── For each step:
  │   ├── If Action:
  │   │   ├── Execute action (e.g., set input)
  │   │   ├── Wait for `duration` if specified
  │   │   └── Proceed to next step
  │   └── If Condition:
  │       ├── Poll every frame until satisfied OR timeout
  │       ├── On satisfaction → proceed to next step
  │       └── On timeout → FAIL with failMessage
  ├── Apply cleanup
  └── Report PASS / FAIL + timing data
```

---

## Writing AutoTest Cases

### File Organization

```
Assets/Tests/AutoTest/Cases/
  smoke/           # Quick sanity tests (< 30s each)
  gameplay/        # Feature-specific tests
  regression/      # Bug reproduction tests
  performance/     # Performance validation tests
```

### Best Practices

1. **Keep tests independent** — each test case must work in isolation. Use `setup` and `cleanup` to ensure clean state.
2. **Set reasonable timeouts** — too short causes flaky tests; too long wastes CI time.
3. **Use descriptive failMessages** — when a condition times out, the message should explain what was expected.
4. **Test one behavior per case** — avoid testing multiple features in a single test case.
5. **Avoid frame-exact timing** — use conditions with tolerances, not fixed frame counts.

---

## Batch Mode Execution

Run AutoTest cases from the command line (CI or local):

```bash
# Run all smoke tests
bash .claude/scripts/unity-game-test.sh smoke --scene Assets/Scenes/TestScene.unity

# Run a specific test case
bash .claude/scripts/unity-game-test.sh run --case Assets/Tests/AutoTest/Cases/smoke/player_walk.json

# Run all tests in a category
bash .claude/scripts/unity-game-test.sh run --category gameplay

# Run with verbose logging
bash .claude/scripts/unity-game-test.sh smoke --scene Assets/Scenes/TestScene.unity --verbose
```

The test runner outputs results in JUnit XML format for CI integration.

---

## Registering Custom Actions and Conditions

Extend the framework by implementing `ITestAction` or `ITestCondition`:

```csharp
// Custom action
public class MyCustomAction : ITestAction
{
    public string ActionName => "MyCustomAction";

    public void Execute(TestActionParams actionParams, AutoTestContext context)
    {
        // Implementation
    }
}

// Custom condition
public class MyCustomCondition : ITestCondition
{
    public string ConditionName => "MyCustomCondition";

    public bool Evaluate(TestConditionParams conditionParams, AutoTestContext context)
    {
        // Return true when condition is satisfied
        return false;
    }
}
```

Register in the assembly's initialization:
```csharp
[assembly: RegisterTestAction(typeof(MyCustomAction))]
[assembly: RegisterTestCondition(typeof(MyCustomCondition))]
```
