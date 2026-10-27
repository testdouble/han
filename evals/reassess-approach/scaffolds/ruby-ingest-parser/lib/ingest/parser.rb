module Ingest
  # Parses the partner feed: one record per line, pipe-delimited fields, with
  # quoted fields that may contain pipes, escaped quotes, and continuation
  # lines that start with a tab.
  class Parser
    RECORD = /\A(?<type>[A-Z]{2,4})\|(?<id>\d+)\|(?<rest>.*)\z/
    FIELD = /(?:"((?:[^"\\]|\\.)*)"|([^|]*))(?:\||\z)/
    CONTINUATION = /\A\t(.*)\z/

    Record = Struct.new(:type, :id, :fields, :line_number)

    def initialize(io)
      @io = io
    end

    def each_record
      buffer = nil
      line_number = 0
      @io.each_line do |raw|
        line_number += 1
        line = raw.chomp
        if (m = CONTINUATION.match(line))
          raise ParseError, "continuation without a record at line #{line_number}" if buffer.nil?

          buffer << "\n" << m[1]
          next
        end
        yield build(buffer, line_number - 1) if buffer
        buffer = line.dup
      end
      yield build(buffer, line_number) if buffer
    end

    private

    def build(line, line_number)
      m = RECORD.match(line)
      raise ParseError, "malformed record at line #{line_number}" unless m

      fields = []
      rest = m[:rest]
      rest.scan(FIELD) do |quoted, bare|
        value = quoted ? quoted.gsub(/\\(.)/, '\1') : bare
        fields << value
      end
      fields.pop if fields.last == "" && !rest.end_with?("|")
      Record.new(m[:type], Integer(m[:id]), fields, line_number)
    end
  end

  class ParseError < StandardError; end
end
