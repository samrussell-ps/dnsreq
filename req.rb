#!/usr/bin/env ruby

require './lib/request'
require './lib/response'
require 'socket'

domain = ARGV[0]
server = ARGV[1]
request_type = ARGV[2]
request_id = 0x1234

packed_request = Request.new(domain: domain, request_type: request_type, request_id: request_id).pack

socket = UDPSocket.new
socket.connect(server, 53)
socket.send(packed_request, 0)

packed_response = socket.recv(1500)

response = Response.unpack(packed_response)

puts response.answers.first.to_s
