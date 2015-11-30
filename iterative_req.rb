#!/usr/bin/env ruby

require './lib/recursive_query'

domain = ARGV[0]
server = ARGV[1]
request_type = ARGV[2]

puts RecursiveQuery.new(domain: domain, server: server, request_type: request_type).run
