import iters

def formatAttributes(attributes) {
  return iters.reduce(attributes, | attrs, attribute | {
    if (attribute.value == nil) {
      return '${attrs} ${attribute.key}'
    }
    # var quoteEscape = attribute.value.index_of('\'') != -1
    # var quote = quoteEscape ? '"' : '\''
    var quote = '"'
    return '${attrs} ${attribute.key}=${quote}${attribute.value}${quote}'
  }, '')
}

def html(tree, options) {
  var res = ''
  for node in tree {
    if is_list(node) {
      res += html(node, options)
    } else  if (node.type == 'text') {
      res += node.content
    } else if (node.type == 'comment') {
      res += '<!--${node.content}-->'
    } else  {  
    var isSelfClosing = options.voidTags.contains(node.tagName.lower())
    res += isSelfClosing ? '<${node.tagName}${formatAttributes(node.attributes)}>' : 
      '<${node.tagName}${formatAttributes(node.attributes)}>${html(node.children, options)}</${node.tagName}>'
    }
  }
  return res
}
