require 'name'

class ResourceRecord
  attr_reader :name, :rdata

  def initialize(name:, record_type:, record_class:, record_ttl:, rdata:)
    @name = name
    @record_type = record_type
    @record_class = record_class
    @record_ttl = record_ttl
    @rdata = rdata
  end

  def self.unpack(packed_stream, packed_response)
    name = Name.unpack(packed_stream, packed_response)
    record_type = packed_stream.read(2).unpack('n').first
    record_class = packed_stream.read(2).unpack('n').first
    record_ttl = packed_stream.read(4).unpack('N').first
    rdata_length = packed_stream.read(2).unpack('n').first

    rdata = packed_stream.read(rdata_length)

    new(name: name, record_type: record_type, record_class: record_class, record_ttl: record_ttl, rdata: rdata)
  end
end
