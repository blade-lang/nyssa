import iters

var rx_lt = '/</'
var rx_gt = '/>/'
var rx_space = '/\\t|\\r|\uf8ff/u'
var rx_escape = '/\\\\([\\\\\|`*_{}\[\]()#+\-~])/'
var rx_hr = '/^([*\-=_] *){3,}$/m'
var rx_blockquote = '/\\n *&gt; *((.|\\n)*?)(?=(\\n|$){2})/'
var rx_list = '/\\n( *)(?:[*\-+]|((\d+)|([a-z])|[A-Z])[.)]) +((.|\\n)*?)(?=(\\n|$){2})/'
var rx_listjoin = '/<\/(ol|ul)>\\n\\n<\1>/'
var rx_highlight = '/(^|[^A-Za-z\d\\\\])(([*_])|(~)|(\^)|(--)|(\+\+)|`)(\2?)([^<]*?)\2\8(?!\2)(?=\W|_|$)/s'
var rx_code = '/\\n((```|~~~).*\\n?((.|\\n)*?)\\n?\\2|((    .*?\\n)+))/'
var rx_link = '/((!?)\[(.*?)\]\((.*?)( ".*")?\)|\\\\([\\`*_{}\[\]()#+\-.!~]))/'
var rx_table = '/\\n(( *\|.*?\| *\\n)+)/'
var rx_thead = '/^.*\\n( *\|( *\:?-+\:?-+\:? *\|)* *\\n|)/'
var rx_row = '/.*\\n/'
var rx_cell = '/\||(.*?[^\\\\])\|/'
var rx_heading = '/(?=^|>|\\n)([>\s]*?)(#{1,6}) (.*?)( #*)? *(?=\\n|$)/'
var rx_para = '/(?=^|>|\\n)\s*\\n+([^<]+?)\\n+\s*(?=\\n|<|$)/'
var rx_stash = '/-\d+\uf8ff/u'
var rx_weblink = '/((?<!href=")https?:\/\/[^\s\<]+)/'
var rx_email = '/[0-9a-zA-Z_+]+([-.]{0,1}[0-9a-zA-Z_+])*@([0-9a-zA-Z_]+[-.]+)+[0-9a-zA-Z_]{2,9}/'

def draw_replace(str, pattern, fn) {
  var matches = str.matches(pattern)
  if matches {
    var str_dup = str[,], index = 0, mc_len = matches[0].length()

    # align consecutive result sizes
    iter var i = 1; i < matches.length(); i++ {
      if matches[i].length() < mc_len {
        for j in 0..(mc_len - matches[i].length()) {
          matches[i].insert('', 0)
        }
      }
    }

    var last_index = -1
    iter var i = 0; i < mc_len; i++ {
      var replacement = ''
      index = str_dup.index_of(matches[0][i], index)
      if last_index == index {
        index = str_dup.index_of(matches[0][i], index++)
      }
      last_index = index
      using matches.length() {
        when 1 replacement = fn(mc_len > i ? matches[0][i] : '', index)
        when 2 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', index)
        when 3 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', str)
        when 4 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', str)
        when 5 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', str)
        when 6 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', str)
        when 7 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', str)
        when 8 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', matches[7].length() > i ? matches[7][i] : '', str)
        when 9 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', matches[7].length() > i ? matches[7][i] : '', matches[8].length() > i ? matches[8][i] : '', str)
        when 10 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', matches[7].length() > i ? matches[7][i] : '', matches[8].length() > i ? matches[8][i] : '', matches[9].length() > i ? matches[9][i] : '', str)
        when 11 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', matches[7].length() > i ? matches[7][i] : '', matches[8].length() > i ? matches[8][i] : '', matches[9].length() > i ? matches[9][i] : '', matches[10].length() > i ? matches[10][i] : '', str)
        when 12 replacement = fn(mc_len > i ? matches[0][i] : '', matches[1].length() > i ? matches[1][i] : '', matches[2].length() > i ? matches[2][i] : '', matches[3].length() > i ? matches[3][i] : '', matches[4].length() > i ? matches[4][i] : '', matches[5].length() > i ? matches[5][i] : '', matches[6].length() > i ? matches[6][i] : '', matches[7].length() > i ? matches[7][i] : '', matches[8].length() > i ? matches[8][i] : '', matches[9].length() > i ? matches[9][i] : '', matches[10].length() > i ? matches[10][i] : '', matches[11].length() > i ? matches[11][i] : '', str)
      }

      str = str.replace(matches[0][i], replacement, false)
    }
  }
  return str
}

def to36(num) {
  var r = ord(num.upper())
  if r >= 48 and r <= 57 return r - 48
  else if r >= 65 and r <= 90 return r - 55
  return 0/0  # return NaN
}

def markdown(src) {

  def replace(rex, fn) {
    if is_string(fn) {
      src = src.replace(rex, fn)
    } else {
      src = draw_replace(src, rex, fn)
    }
  }

  def element(tag, content) {
    return '<' + tag + '>' + content + '</' + tag + '>'
  }

  def highlight(src) {
    return draw_replace(src, rx_highlight, |all, _, p1, emp, sub, sup, small, big, p2, content, _1| {
      var type = emp ? (p2 ? 'strong' : 'em')
      : sub ? (p2 ? 's' : 'sub')
      : sup ? 'sup'
      : small ? 'small'
      : big ? 'big'
      : 'code'

      # handle cases such as:
      # ```sh
      # some command
      # ```
      # which will leave things like:
      # sh
      #   some command
      # in the content
      if type == 'code' and content.index_of('\n') > -1 {
        content = '\n'.join(content.split('\n')[1,]).replace('/`+$/D', '')
      }

      return _ + element(type, highlight(content))
    })
  }

  def blockquote(src) {
    return draw_replace(src, rx_blockquote, |all, content, _1, _2, _3| {
      return element('blockquote', blockquote(highlight(content.replace('/^ *&gt; */sm', ''))))
    })
  }

  def list(src) {
    return draw_replace(src, rx_list, |all, ind, ol, num, low, content, _, _1, _2| {
      var entry = element('li', highlight('</li><li>'.join(iters.map(content.split(
        '/\\n ?${ind}(?:(?:\d+|[a-zA-Z])[.)]|[*\-+]) +/'
      ), list))))
      
      return '\n' + (ol ? ('<ol start="' + (num ? 
          ol + '">' : 
          to36(ol) - 9 + '" style="list-style-type:' + (low ? 'low' : 'upp') + 'er-alpha">') + entry + '</ol>')
        : element('ul', entry))
    })
  }

  def unesc(str) {
    # echo str
    return str.replace(rx_escape, '$1')
  }

  var stash = {}
  var si = 0

  src = '\n' + src + '\n'

  src = src.replace(rx_lt, '&lt;')
  src = src.replace(rx_gt, '&gt;')
  replace(rx_space, '  ')

  # blockquote
  src = blockquote(src)

  # horizontal rule
  src = src.replace(rx_hr, '<hr/>')

  # list
  src = list(src)
  replace(rx_listjoin, '')

  # code
  replace(rx_code, |all, p1, p2, p3, p4, _, _1, _2| {
    stash[si--] = element('pre', element('code', (p3 or p4).replace('/^    /', '')))
    return si + '\uf8ff'
  })

  # link or image
  replace(rx_link, |all, p1, p2, p3, p4, p5, p6| {
    stash[si--] = p4 ? (p2 ? 
      '<img src="' + p4 + '" alt="' + p3 + '"/>' : 
      '<a href="' + p4 + '">' + unesc(highlight(p3)) + '</a>') : 
      p6
    return si + '\uf8ff'
  });

  # table
  replace(rx_table, |all, table, _, _1| {
    var sep = table.match(rx_thead)[1]
    return '\n' + element('table',
      draw_replace(table, rx_row, |row, ri| {
        return row == sep ? '' : element('tr', draw_replace(row, rx_cell, |all, cell, ci| {
          return ci > 0 ? element(sep and ri == 0 ? 'th' : 'td', unesc(highlight(cell or ''))) : '|'
        }))
      })
    )
  })
  # table fix
  src = src.replace('<tr>|<td>', '<tr><td>', false)
  src = src.replace('<tr>|<th>', '<tr><th>', false)

  # heading
  replace(rx_heading, |all, _, p1, p2, _2| {
    return _ + element('h' + p1.length(), unesc(highlight(p2))) 
  })

  # paragraph
  replace(rx_para, |all, content, _| {
    return element('p', unesc(highlight(content))) 
  })

  # stash
  replace(rx_stash, |all, _| {  
    # echo (all)
    return stash[to_int(to_number(all))] 
  })

  # autolinks
  src = src.replace(rx_weblink, '<a href="$0" target="_blank">$0</a>')
  src = src.replace(rx_email, '<a href="mailto:$0">$0</a>')

  return src.trim()
}
