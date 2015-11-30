require './lib/resource_record'
require './lib/name'

class Request
  def initialize(domain:, request_type:, request_id:)
    @domain = domain
    @request_type = request_type
    @request_id = request_id
  end

  def pack
    packed_id +
      packed_flags +
      packed_counts +
      packed_domain_string +
      packed_request_type +
      packed_request_class
  end

  private

  def packed_id
    [@request_id].pack('n')
  end

  def packed_flags
    [0].pack('n')
  end

  def packed_counts
    [1].pack('n') +
    [0].pack('n') +
    [0].pack('n') +
    [0].pack('n')
  end

  def packed_domain_string
    Name.new(name: @domain).pack
  end

  def packed_request_type
    [ResourceRecord::RECORD_TYPES[@request_type]].pack('n')
  end

  def packed_request_class
    [1].pack('n')
  end
end
