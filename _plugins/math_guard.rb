# frozen_string_literal: true

# Kramdown only treats $$...$$ as math. Notes are written with the usual
# TeX delimiters: $...$ for inline math and $$...$$ for display math.
# Pull those spans out before Markdown runs so underscores stay underscores,
# then put them back as \(...\) and \[...\] for MathJax.
module MathGuard
  CODE_TOKEN = "MZQCODE"
  MATH_TOKEN = "MZQMATH"
  FENCE = /^(?<fence>`{3,}|~{3,})[^\n]*\n.*?\n\k<fence>[ \t]*$/m
  INLINE_CODE = /`+[^`\n]*`+/
  DISPLAY_MATH = /(?<!\\)\$\$(.+?)(?<!\\)\$\$/m
  INLINE_MATH = /(?<!\\)\$([^$\n]+?)(?<!\\)\$/

  module_function

  def protect_code(text)
    slots = []
    protected = text.to_s.gsub(FENCE) do
      slots << Regexp.last_match(0)
      code_token(slots.length - 1)
    end
    protected = protected.gsub(INLINE_CODE) do
      slots << Regexp.last_match(0)
      code_token(slots.length - 1)
    end
    [protected, slots]
  end

  def restore_code(text, slots)
    slots.each_with_index.reduce(text) do |current, (slot, index)|
      current.gsub(code_token(index)) { slot }
    end
  end

  def extract(text)
    tokens = []
    without_display = text.gsub(DISPLAY_MATH) do
      tokens << [:display, Regexp.last_match(1).strip]
      math_token(tokens.length - 1)
    end
    without_inline = without_display.gsub(INLINE_MATH) do
      body = Regexp.last_match(1)
      if body.empty? || body.start_with?(" ") || body.end_with?(" ")
        Regexp.last_match(0)
      else
        tokens << [:inline, body]
        math_token(tokens.length - 1)
      end
    end
    [without_inline, tokens]
  end

  def restore(html, tokens)
    return html if tokens.nil? || tokens.empty?

    tokens.each_with_index.reduce(html) do |current, ((kind, tex), index)|
      token = math_token(index)
      escaped = escape_tex(tex)
      if kind == :display
        block = %(<div class="math-display">\\[#{escaped}\\]</div>)
        current = current.gsub(%r{<p>\s*#{token}\s*</p>}) { block }
        current.gsub(token) { block }
      else
        current.gsub(token) { %(<span class="math-inline">\\(#{escaped}\\)</span>) }
      end
    end
  end

  def code_token(index)
    "#{CODE_TOKEN}#{index}END"
  end

  def math_token(index)
    "#{MATH_TOKEN}#{index}END"
  end

  def escape_tex(tex)
    tex.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
  end
end

Jekyll::Hooks.register [:pages, :documents], :pre_render do |doc|
  protected_text, code_slots = MathGuard.protect_code(doc.content)
  stripped, tokens = MathGuard.extract(protected_text)
  doc.content = MathGuard.restore_code(stripped, code_slots)
  doc.data["math_tokens"] = tokens
end

Jekyll::Hooks.register [:pages, :documents], :post_convert do |doc|
  doc.content = MathGuard.restore(doc.content, doc.data["math_tokens"])
end
