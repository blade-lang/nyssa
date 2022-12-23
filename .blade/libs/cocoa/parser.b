def parser(tokens, options) {
  var root = {
    tagName: nil, 
    children: [],
  }
  var state = {
    tokens: tokens, 
    options: options, 
    cursor: 0,
    stack: [
      root
    ],
  }
  parse(state)
  return root.children
}

def hasTerminalParent(tagName, stack, terminals) {
  var tagParents = terminals.get(tagName, nil)
  if tagParents {
    var currentIndex = stack.length() - 1
    while currentIndex >= 0 {
      var parentTagName = stack[currentIndex].tagName
      if parentTagName == tagName {
        break
      }
      if tagParents.contains(parentTagName) {
        return true
      }
      currentIndex--
    }
  }
  return false
}

def rewindStack(stack, newLength, childrenEndPosition, endPosition) {
  stack[newLength].position.end = endPosition
  var len = stack.length()
  iter var i = newLength + 1; i < len; i++ {
    stack[i].position.end = childrenEndPosition
  }
  stack[newLength,]
}

def parse(state) {
  var nodes = state.stack[state.stack.length() - 1].children
  var len = state.tokens.length()
  while state.cursor < len {
    var token = state.tokens[state.cursor]
    if token.type != 'tag-start' {
      nodes.append(token)
      state.cursor++
      continue
    }

    var tagToken = state.tokens[state.cursor++]
    state.cursor++
    var tagName = tagToken.content.lower()
    if token.close {
      var index = state.stack.length()
      var shouldRewind = false
      while index-- > -1 {
        if state.stack[index].tagName == tagName {
          shouldRewind = true
          break
        }
      }
      while state.cursor < len {
        var endToken = state.tokens[state.cursor]
        if endToken.type != 'tag-end' break
        state.cursor++
      }
      if shouldRewind {
        rewindStack(state.stack, index, token.position.start, state.tokens[state.cursor - 1].position.end)
        break
      } else {
        continue
      }
    }

    var isClosingTag = state.options.closingTags.contains(tagName.lower())
    var shouldRewindToAutoClose = isClosingTag
    if shouldRewindToAutoClose {
      var terminals = state.options.get('closingTagAncestorBreakers')
      shouldRewindToAutoClose = !hasTerminalParent(tagName.lower(), state.stack, terminals)
    }

    if shouldRewindToAutoClose {
      # rewind the stack to just above the previous
      # closing tag of the same name
      var currentIndex = state.stack.length() - 1
      while currentIndex > 0 {
        if tagName == state.stack[currentIndex].tagName {
          rewindStack(state.stack, currentIndex, token.position.start, token.position.start)
          var previousIndex = currentIndex - 1
          nodes = state.stack[previousIndex].children
          break
        }
        currentIndex = currentIndex - 1
      }
    }

    var attributes = []
    var attrToken
    while state.cursor < len {
      attrToken = state.tokens[state.cursor]
      if attrToken.type == 'tag-end' break
      attributes.append(attrToken.content)
      state.cursor++
    }

    state.cursor++
    var children = []
    var position = {
      start: token.position.start,
      end: attrToken.position.end
    }
    var elementNode = {
      type: 'element',
      tagName: tagToken.content,
      attributes: attributes,
      children: children,
      position: position,
    }
    nodes.append(elementNode)

    var hasChildren = !(attrToken.close or state.options.voidTags.contains(tagName.lower()))
    if hasChildren {
      var size = state.stack.append({
        tagName: tagName, 
        children: children, 
        position: position,
      })
      var innerState = {
        tokens: state.tokens, 
        options: state.options, 
        cursor: state.cursor, 
        stack: state.stack,
      }
      parse(innerState)
      state.cursor = innerState.cursor
      var rewoundInElement = state.stack.length() == size
      if rewoundInElement {
        elementNode.position.end = state.tokens[state.cursor - 1].position.end
      }
    }
  }
}
