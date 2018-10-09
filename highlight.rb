require "iro"

using Module.new {
  refine(Array) do
    def type
      self[0]
    end

    def lineno
      self[1] - 1
    end

    def column
      self[2] - 1
    end

    def length
      self[3]
    end
  end
}

INLINE_CMD_MAP =
  {
    "String" => "code-string",
    "Charactor" => "code-character",
    "Number" => "code-number",
    "Float" => "code-float",
    "Comment" => "code-comment",
    "Type" => "code-type",
    "Delimiter" => "code-delimiter",
    "rubyDefine" => "code-define",
    "keyword" => "code-keyword",
    "rubyFunction" => "code-function",
    "rubyLocalVariable" => "code-lvar"
  }

def highlight_positions(code)
  tokens = Iro::Ruby::Parser.tokens(code)
  tokens.flat_map {|group, poss|
    poss.map {|pos|
      [INLINE_CMD_MAP.fetch(group), *pos]
    }
  }.sort_by {|pos|
    [pos.lineno, pos.column]
  }
end

def highlight_code(cmd, code)
  code.each_char.chunk {|c| c == " " }.map do |space, cs|
    if space
      "\\code-space;" * cs.size
    elsif cs.empty?
        ""
    else
        "\\#{cmd}(`#{cs.join}`);"
    end
  end.join
end

def highlight(code)
  hs = highlight_positions(code)

  saty = ''
  code.each_line.with_index do |line, lineno|
    line_hs = hs.select {|h| h.lineno == lineno }

    saty << highlight_code("code-other", line) and next if line_hs.empty?

    last_column = 0
    line_hs.each do |h|
      saty << highlight_code("code-other", line[last_column...h.column])
      last_column = h.column + h.length
      saty << highlight_code(h.type, line[h.column...last_column])
    end
    saty << highlight_code("code-other", line[last_column..-1])
    saty << "\\code-new-line;"
  end
  saty
end
