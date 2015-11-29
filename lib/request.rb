class Request
  REQUEST_TYPES = {
    'A' => 1
  }

  def initialize(domain:, server:, request_type:, request_id:)
    @domain = domain
    @server = server
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
    @domain.split('.').map do |octets|
      [octets.length].pack('C') + [octets].pack('a*')
    end.join + [0].pack('C')
  end

  def packed_request_type
    [REQUEST_TYPES[@request_type]].pack('n')
  end

  def packed_request_class
    [1].pack('n')
  end
end
