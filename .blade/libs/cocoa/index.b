import .tags { * }
import .lexer
import .parser
import .format
import .html

var parseDefaults = {
  voidTags: voidTags,
  closingTags: closingTags,
  childlessTags: childlessTags,
  closingTagAncestorBreakers: closingTagAncestorBreakers,
  includePositions: false
}

def decode(str, options) {
  # create options
  if !options options = parseDefaults
  else {
    for key, value in parseDefaults {
      if options.get(key, nil) == nil {
        options.set(key, value)
      }
    }
  }
  
  var tokens = lexer(str, options)
  var nodes = parser(tokens, options)
  return format(nodes, options)
}

def encode(ast, options) {
  if !options options = parseDefaults
  return html(ast, options)
}
