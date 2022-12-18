/**
 * Tags which contain arbitary non-parsed content
 * For example: <script> JavaScript should not be parsed
 */
var childlessTags = ['style', 'script', 'template']

/**
 * Tags which auto-close because they cannot be nested
 * For example: <p>Outer<p>Inner is <p>Outer</p><p>Inner</p>
 */
var closingTags = [
  'html', 'head', 'body', 'dt', 'dd', 'li', 'option',
  'thead', 'th', 'tbody', 'tr', 'td', 'tfoot', 'colgroup'
]

/**
 * Closing tags which have ancestor tags which may exist within 
 * them which prevent the closing tag from auto-closing.
 * For example: in <li><ul><li></ul></li>, the top-level <li> 
 * should not auto-close.
 */
var closingTagAncestorBreakers = {
  li: ['ul', 'ol', 'menu'],
  dt: ['dl'],
  dd: ['dl'],
  tbody: ['table'],
  thead: ['table'],
  tfoot: ['table'],
  tr: ['table'],
  td: ['table']
}

/**
 * Tags which do not need the closing tag
 * For example: <img> does not need </img>
 */
var voidTags = [
  '!doctype', 'area', 'base', 'br', 'col', 'command',
  'embed', 'hr', 'img', 'input', 'keygen', 'link',
  'meta', 'param', 'source', 'track', 'wbr'
]
