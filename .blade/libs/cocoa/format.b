import iters

def splitHead(str, sep) {
  var idx = str.index_of(sep)
  if idx == -1 return [str]
  return [str[0, idx], str[idx + sep.length(),]]
}

def unquote(str) {
  var car = str[0]
  var end = str.length() - 1
  var isQuoteStart = car == '"' or car == "'"
  if isQuoteStart and car == str[end] {
    return str[1, end]
  }
  return str
}

def format(nodes, options) {
  return iters.map(nodes, | node | {
    var type = node.type
    var outputNode = type == 'element' ? {
        type: type,
        tagName: node.tagName,
        attributes: formatAttributes(node.attributes),
        children: format(node.children, options),
      } : { 
        type: type, 
        content: node.content, 
      }
    if options.get('includePositions', false) {
      outputNode.position = node.position
    }
    return outputNode
  })
}

def formatAttributes(attributes) {
  return iters.map(attributes, | attribute | {
    var parts = splitHead(attribute.trim(), '=')
    var key = parts[0]
    var value
    if parts.length() > 1 {
      value = is_string(parts[1]) ? unquote(parts[1]) : nil
    }
    return {key: key, value: value}
  })
}
