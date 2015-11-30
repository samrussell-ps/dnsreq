require './lib/request'
require './lib/response'
require './lib/resource_record'
require 'socket'

class RecursiveQuery
  def initialize(domain:, server: '192.5.5.241', request_type:)
    @domain = domain
    @server = server
    @request_type = request_type
  end

  def run
    request_id = 0x1234

    packed_request = Request.new(domain: @domain, request_type: @request_type, request_id: request_id).pack

    socket = UDPSocket.new
    socket.connect(@server, 53)
    socket.send(packed_request, 0)

    packed_response = socket.recv(1500)

    response = Response.unpack(packed_response)

    while response.answers.length == 0
      puts "no response :O"
      # just grab an IP from additional_rrs
      possible_nses = response.additional_rrs.select { |rr| rr.record_type == ResourceRecord::RECORD_TYPES['A'] }

      if possible_nses.length > 0
        # send the request to one of the NSes
        next_server = possible_nses.first.to_s
        puts "trying #{next_server}"
        socket = UDPSocket.new
        socket.connect(next_server, 53)
        socket.send(packed_request, 0)
        packed_response = socket.recv(1500)
        response = Response.unpack(packed_response)
      else
        # try make an IP from the authority section
        possible_ns_names = response.authority_rrs.select { |rr| rr.record_type == ResourceRecord::RECORD_TYPES['NS'] }
        if possible_ns_names.length > 0
          puts "trying authorities"
          next_ns = possible_ns_names.first.to_s
          # lookup
          next_server = RecursiveQuery.new(domain: next_ns, request_type: 'A').run
          puts "trying #{next_server}"
          socket = UDPSocket.new
          socket.connect(next_server, 53)
          socket.send(packed_request, 0)
          packed_response = socket.recv(1500)
          response = Response.unpack(packed_response)
        else
          # we're screwed!
          puts "WE CANNAE DO IT"
          break
        end
      end
    end
    response.answers.first.to_s
  end
end
