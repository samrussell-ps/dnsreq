require 'stringio'
require './lib/name'
require './lib/resource_record'

class Response
  HEADER_UNPACK_STRING = 'nnnnnn'
  HEADER_LENGTH = 12

  attr_reader :request_id, :questions, :answers

  def initialize(request_id:, questions:, answers:)
    @request_id = request_id
    @questions = questions
    @answers = answers
  end

  def self.unpack(packed_response)
    packed_stream = StringIO.new(packed_response)

    packed_header = packed_stream.read(HEADER_LENGTH)

    request_id, flags, questions_count, answers_count, authority_rrs_count, additional_rrs_count = packed_header.unpack(HEADER_UNPACK_STRING)

    questions = unpack_questions(packed_stream, packed_response, questions_count)

    answers = unpack_resource_records(packed_stream, packed_response, answers_count)

    new(request_id: request_id, questions: questions, answers: answers)
  end

  private

  def self.unpack_questions(packed_stream, packed_response, count)
    count.times.map { unpack_question(packed_stream, packed_response) }
  end

  def self.unpack_question(packed_stream, packed_response)
    question_octets = []

    loop do
      octets = unpack_question_octets(packed_stream)

      question_octets << octets

      break unless octets
    end

    question_type = packed_stream.read(2)
    question_class= packed_stream.read(2)

    question_octets.compact.join('.')
  end

  def self.unpack_question_octets(packed_stream)
    packed_octets_length = packed_stream.read(1)
    octets_length = packed_octets_length.unpack('C').first

    packed_stream.read(octets_length) if octets_length > 0
  end

  def self.unpack_resource_records(packed_stream, packed_response, count)
    count.times.map { ResourceRecord.unpack(packed_stream, packed_response) }
  end
end
