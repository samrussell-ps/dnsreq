require 'stringio'

class Response
  HEADER_UNPACK_STRING = 'nnnnnn'
  HEADER_LENGTH = 12

  attr_reader :request_id, :questions

  def initialize(request_id:, questions: questions)
    @request_id = request_id
    @questions = questions
  end

  def self.unpack(packed_response)
    packed_stream = StringIO.new(packed_response)

    packed_header = packed_stream.read(HEADER_LENGTH)

    request_id, flags, questions_count, answers_count, authority_rrs_count, additional_rrs_count = packed_header.unpack(HEADER_UNPACK_STRING)

    questions = unpack_questions(packed_stream, questions_count)

    new(request_id: request_id, questions: questions)
  end

  private

  def self.unpack_questions(packed_stream, count)
    count.times.map { unpack_question(packed_stream) }
  end

  def self.unpack_question(packed_stream)
    question_octets = []

    loop do
      octets = unpack_question_octets(packed_stream)

      break unless octets
    end

    question_octets.join('.')
  end

  def self.unpack_question_octets(packed_stream)
    packed_octets_length = packed_stream.read(1)
    octets_length = packed_octets_length.unpack('C').first

    packed_stream.read(octets_length) if octets_length > 0
  end
end
