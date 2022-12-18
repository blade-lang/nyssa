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
  return ''.join(iters.map(tree, | node | {
    if is_list(node)
      return html(node, options)

    if (node.type == 'text')
      return node.content
    if (node.type == 'comment')
      return '<!--${node.content}-->'
      
    var isSelfClosing = options.voidTags.contains(node.tagName.lower())
    return isSelfClosing ? '<${node.tagName}${formatAttributes(node.attributes)}>' : 
      '<${node.tagName}${formatAttributes(node.attributes)}>${html(node.children, options)}</${node.tagName}>'
  }))
}
