def feedPosition(position, str, len) {
  var start = position.index
  var end = position.index = start + len
  iter var i = start; i < end; i++ {
    var char = str[i]
    if char == '\n' {
      position.line++
      position.column = 1
    } else {
      position.column++
    }
  }
}

def jumpPosition(position, str, end) {
  var len = end - position.index
  return feedPosition(position, str, len)
}

def lexer(str, options) {
  var state = {
    str: str,
    options: options,
    position: {
      index: 0,
      column: 1,
      line: 1
    },
    tokens: []
  }
  lex(state)
  return state.tokens
}

def lex(state) {
  var len = state.str.length()
  while state.position.index < len {
    var start = state.position.index
    lexText(state)
    if state.position.index == start {
      var isComment = state.str.index_of('!--', start + 1) > -1
      if isComment {
        lexComment(state)
      } else {
        var tagName = lexTag(state)
        var safeTag = tagName.lower()
        if state.get('childlessTags', []).contains(safeTag.lower()) {
          lexSkipTag(tagName, state)
        }
      }
    }
  }
}

var alphanumeric = '/[A-Za-z0-9]/'

def findTextEnd(str, index) {
  while true {
    var textEnd = str.index_of('<', index)
    if textEnd == -1 {
      return textEnd
    }
    var char = str[textEnd + 1]
    if char == '/' or char == '!' or char.match(alphanumeric) {
      return textEnd
    }
    index = textEnd + 1
  }
}

def lexText(state) {
  var type = 'text'
  var textEnd = findTextEnd(state.str, state.position.index)
  if textEnd == state.position.index return
  if textEnd == -1 {
    textEnd = state.str.length()
  }

  var start = state.position.clone()
  var content = state.str[state.position.index, textEnd]
  jumpPosition(state.position, state.str, textEnd)
  var end = state.position.clone()
  state.tokens.append({
    type: type, 
    content: content, 
    position: {
      start: start, 
      end: end,
    }
  })
}

def lexComment(state) {
  var start = state.position.clone()
  feedPosition(state.position, state.str, 4) # "<!--".length()

  var contentEnd = state.str.index_of('-->', state.position.index)
  var commentEnd = contentEnd + 3 # "-->".length()
  if contentEnd == -1 {
    contentEnd = commentEnd = state.str.length()
  }

  var content = state.str[state.position.index, contentEnd]
  jumpPosition(state.position, state.str, commentEnd)
  state.tokens.append({
    type: 'comment',
    content: content,
    position: {
      start: start,
      end: state.position.clone()
    }
  })
}

def lexTag(state) {
  {
    var secondChar = state.str[state.position.index + 1]
    var close = secondChar == '/'
    var start = state.position.clone()
    feedPosition(state.position, state.str, close ? 2 : 1)
    state.tokens.append({
      type: 'tag-start', 
      close: close, 
      position: {
        start: start,
      }
    })
  }

  var tagName = lexTagName(state)
  lexTagAttributes(state)

  {
    var firstChar = state.str[state.position.index]
    var close = firstChar == '/'
    feedPosition(state.position, state.str, close ? 2 : 1)
    var end = state.position.clone()
    state.tokens.append({
      type: 'tag-end', 
      close: close, 
      position: {
        end: end,
      }
    })
  }

  return tagName
}

# See https:#developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#special-white-space
var whitespace = '/\s/'

def isWhitespaceChar(char) {
  return char.match(whitespace)
}

def lexTagName(state) {
  var len = state.str.length()
  var start = state.position.index
  while start < len {
    var char = state.str[start]
    var isTagChar = !(isWhitespaceChar(char) or char == '/' or char == '>')
    if isTagChar break
    start++
  }

  var end = start + 1
  while end < len {
    var char = state.str[end]
    var isTagChar = !(isWhitespaceChar(char) or char == '/' or char == '>')
    if !isTagChar break
    end++
  }

  jumpPosition(state.position, state.str, end)
  var tagName = state.str[start, end]
  state.tokens.append({
    type: 'tag',
    content: tagName
  })
  return tagName
}

def lexTagAttributes(state) {
  var cursor = state.position.index
  var quote = nil # nil, single-, or double-quote
  var wordBegin = cursor # index of word start
  var words = [] # "key", "key=value", "key='value'", etc
  var len = state.str.length()
  while cursor < len {
    var char = state.str[cursor]
    if quote {
      var isQuoteEnd = char == quote
      if isQuoteEnd {
        quote = nil
      }
      cursor++
      continue
    }

    var isTagEnd = char == '/' or char == '>'
    if isTagEnd {
      if cursor != wordBegin {
        words.append(state.str[wordBegin, cursor])
      }
      break
    }

    var isWordEnd = isWhitespaceChar(char)
    if isWordEnd {
      if cursor != wordBegin {
        words.append(state.str[wordBegin, cursor])
      }
      wordBegin = cursor + 1
      cursor++
      continue
    }

    var isQuoteStart = char == '\'' or char == '"'
    if isQuoteStart {
      quote = char
      cursor++
      continue
    }

    cursor++
  }
  jumpPosition(state.position, state.str, cursor)

  var wLen = words.length()
  var type = 'attribute'
  iter var i = 0; i < wLen; i++ {
    var word = words[i]
    var isNotPair = word.index_of('=') == -1
    if isNotPair and words.length() > i + 1 {
      var secondWord = words[i + 1]
      if secondWord and secondWord.index_of('=') > -1 {
        if secondWord.length() > 1 {
          var newWord = word + secondWord
          state.tokens.append({type: type, content: newWord})
          i += 1
          continue
        }
        var thirdWord = words[i + 2]
        i += 1
        if thirdWord {
          var newWord = word + '=' + thirdWord
          state.tokens.append({type: type, content: newWord})
          i += 1
          continue
        }
      }
    }
    if word.ends_with('=') {
      var secondWord = words[i + 1]
      if secondWord and secondWord.index_of('=') > -1 {
        var newWord = word + secondWord
        state.tokens.append({type: type, content: newWord})
        i += 1
        continue
      }

      var newWord = word[0, -1]
      state.tokens.append({type: type, content: newWord})
      continue
    }

    state.tokens.append({type: type, content: word})
  }
}

def lexSkipTag(tagName, state) {
  var safeTagName = tagName.lower()
  var len = state.str.length()
  var index = state.position.index
  while index < len {
    var nextTag = state.str.index_of('</', index)
    if nextTag == -1 {
      lexText(state)
      break
    }

    var tagStartPosition = state.position.clone()
    jumpPosition(tagStartPosition, state.str, nextTag)
    var tagState = {
      str: state.str, 
      position: tagStartPosition, 
      tokens: [],
    }
    var name = lexTag(tagState)
    if safeTagName != name.lower() {
      index = tagState.position.index
      continue
    }

    if nextTag != state.position.index {
      var textStart = state.position.clone()
      jumpPosition(state.position, state.str, nextTag)
      state.tokens.append({
        type: 'text',
        content: state.str[textStart.index, nextTag],
        position: {
          start: textStart,
          end: state.position.clone(),
        }
      })
    }

    state.tokens.extend(tagState.tokens)
    # state.tokens.append(tagState.tokens)
    jumpPosition(state.position, state.str, tagState.position.index)
    break
  }
}
