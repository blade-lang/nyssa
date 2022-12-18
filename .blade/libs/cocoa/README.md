# cocoa

Cocoa is a HTML to Blade object parser and Blade object to HTML converter developed as part of the Nyssa package manager.


### Features

- Preserves whitespace
- Line, column and index positions information


### Usage

```
import cocoa
var asJson = cocoa.decode('<p class="x">Hello <br /></p>')  # convert to blade
echo asJson
echo cocoa.encode(asJson)  # convert to html string
```

### Edge-cases handled
Cocoaa handles a lot of HTML's edge-cases, like:

- Closes unclosed tags `<p><b>...</p>`
- Ignores extra closing tags `<span>...</b></span>`
- Properly handles void tags like `<meta>` and `<img>`
- Properly handles self-closing tags like `<input/>`
- Handles `<!doctype>` and `<-- comments -->`
- Does not parse the contents of `<script>`, `<style>`, and HTML5 `<template>` tags


### Decoding line, column and index positions information

You can show the line, column and index positions by enabling the `includePositions` option.

```
import cocoa
echo cocoa.decode('<img>', {includePositions: true})

/**
 * Output
 * -----------
 * [{type: element, tagName: img, attributes: [], children: [], position: {start: 
 * {index: 0, column: 0, line: 0}, end: {index: 5, column: 5, line: 0}}}]
 */
```
