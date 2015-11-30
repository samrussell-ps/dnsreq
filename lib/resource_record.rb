require './lib/name'
require 'stringio'

class ResourceRecord
  RECORD_TYPES = {
    'A' => 1,
    'NS' => 2,
    'AAAA' => 28
  }
  attr_reader :name, :rdata, :record_type

  def initialize(name:, record_type:, record_class:, record_ttl:, rdata:, packed_response:)
    @name = name
    @record_type = record_type
    @record_class = record_class
    @record_ttl = record_ttl
    @rdata = rdata
    @packed_response = packed_response
  end

  def to_s
    case @record_type
    when RECORD_TYPES['A']
      as_ip_address
    when RECORD_TYPES['NS']
      as_name
    when RECORD_TYPES['AAAA']
      as_ip6_address
    end
  end

  def self.unpack(packed_stream, packed_response)
    name = Name.unpack(packed_stream, packed_response)
    record_type = packed_stream.read(2).unpack('n').first
    record_class = packed_stream.read(2).unpack('n').first
    record_ttl = packed_stream.read(4).unpack('N').first
    rdata_length = packed_stream.read(2).unpack('n').first

    rdata = packed_stream.read(rdata_length)

    new(name: name, record_type: record_type, record_class: record_class, record_ttl: record_ttl, rdata: rdata, packed_response: packed_response)
  end

  private

  def as_ip_address
    @rdata.unpack('C4').join('.')
  end

  def as_name
    rdata_stream = StringIO.new(@rdata)

    name = Name.unpack(rdata_stream, @packed_response).to_s
  end

  def as_ip6_address
    @rdata.unpack('H32').join.scan(/..../).join(':')
  end

end
