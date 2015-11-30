require 'stringio'

class Response
  HEADER_UNPACK_STRING = 'nnnnnn'
  HEADER_LENGTH = 12

  attr_reader :request_id, :questions, :answers

  def initialize(request_id:, questions: questions, answers:)
    @request_id = request_id
    @questions = questions
    @answers = answers
  end

  def self.unpack(packed_response)
    packed_stream = StringIO.new(packed_response)

    packed_header = packed_stream.read(HEADER_LENGTH)

    request_id, flags, questions_count, answers_count, authority_rrs_count, additional_rrs_count = packed_header.unpack(HEADER_UNPACK_STRING)

    questions = unpack_questions(packed_stream, questions_count)

    answers = unpack_resource_records(packed_stream, answers_count)

    new(request_id: request_id, questions: questions, answers: answers)
  end

  private

  def self.unpack_questions(packed_stream, count)
    count.times.map { unpack_question(packed_stream) }
  end

  def self.unpack_question(packed_stream)
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

  def self.unpack_resource_records(packed_stream, count)
    count.times.map { unpack_resource_record(packed_stream) }
  end

  def self.unpack_resource_record(packed_stream)
    name = unpack_name(packed_stream)

  end

  def self.unpack_name(packed_stream)
    name_octets = []

    loop do
      octets = unpack_name_octets(packed_stream)

      name_octets << octets

      break unless octets
    end

    # TODO this is hax but it works for now
    packed_name_class = packed_stream.read(1)
    packed_name_type = packed_stream.read(2)
    packed_ttl = packed_stream.read(4)
    packed_rd_length = packed_stream.read(2)

    rd_length = packed_rd_length.unpack('n').first

    rdata = packed_stream.read(rd_length)

    name_octets.compact.join('.')
  end

  def self.unpack_ip_address(packed_ip_address)
    packed_ip_address.unpack('C4').join('.')
  end

  def self.unpack_name_octets(packed_stream)
    packed_octets_length = packed_stream.read(1)
    octets_length = packed_octets_length.unpack('C').first

    if octets_length >= 0xc0
      # TODO fill this in
      packed_stream.read(1)
      'unknown'
    elsif octets_length > 0
      packed_stream.read(octets_length)
    end
  end
end
