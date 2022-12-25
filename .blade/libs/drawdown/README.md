# drawdown

Drawdown is a Markdown to HTML converted based on the [drawdown](https://github.com/adamvleggett/drawdown)  JavaScript library.

### Supported Features

- Block quotes
- Code blocks
- Links
- Images
- Headings
- Lists (including lettered lists)
- Bold
- Italic
- Strikethrough
- Monospace
- Subscript
- Horizontal rule
- Tables
- Automatic linking

### Unsupported Features

- Line blocks
- Definition lists
- Footnotes
- Twitter/Facebook/YouTube embed
- Inline math equations

### Usage

```
import drawdown
echo drawdown.markdown('# heading')
```

The above will output: `<h1>heading</h1>`.
