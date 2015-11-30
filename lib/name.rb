require 'stringio'

class Name
  attr_reader :name, :length, :offset

  def initialize(name:, length:)
    @name = name
    @length = length
  end

  def to_s
    @name
  end

  def self.unpack(packed_stream, packed_string)
    initial_offset = packed_stream.tell

    name = unpack_name(packed_stream, packed_string)

    bytes_read = packed_stream.tell - initial_offset

    new(name: name, length: bytes_read)
  end

  def self.unpack_name(packed_stream, packed_string)
    name_octets = []

    octets_length = read_octets_length(packed_stream)

    if octets_length < 0xc0
      loop do
        octets = packed_stream.read(octets_length)

        name_octets << octets

        octets_length = read_octets_length(packed_stream)

        break if octets_length == 0
      end

      name_octets.join('.')
    else
      second_octet = packed_stream.read(1).unpack('C').first
      offset = ((octets_length & 0x3f) << 8) | second_octet

      offset_stream = StringIO.new(packed_string)

      offset_stream.seek(offset)

      Name.unpack(offset_stream, packed_string).to_s
    end
  end

  def self.read_octets_length(packed_stream)
    packed_octets_length = packed_stream.read(1)
    packed_octets_length.unpack('C').first
  end
end
