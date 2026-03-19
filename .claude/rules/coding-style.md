# Coding Style Rules

> Supplements the constitution with details it can't cover. If derivable from the constitution, delete it.

## Rule 1: template/ 与 .claude/ 的平行修改 (per Constitution §1, §2)

当同时修改 `template/.claude/` 和 `.claude/` 下的同名文件时，注意区分：
- `template/` 下的版本：保留 `{placeholder}`，面向用户项目
- `.claude/` 下的版本：使用 claude-flow 项目自身的具体内容

修改模板命令逻辑时，两处都要更新。修改项目自身配置时，不要改 template/ 版本。

## Rule 2: 脚本入口统一格式 (per Constitution §3)

所有 Python 脚本遵循统一结构：

```python
# ✅ Correct
#!/usr/bin/env python3
"""
Module docstring with Usage examples.
"""
import ...

def main():
    parser = argparse.ArgumentParser(...)
    ...

if __name__ == "__main__":
    main()
```

## Self-check Checklist

- [ ] template/ 下的文件是否仍包含 {placeholder}（未被意外替换）
- [ ] README.md 的命令表、模板结构是否与 template/ 一致
- [ ] Python 脚本是否引入了标准库以外的依赖
