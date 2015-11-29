require 'spec_helper'
require './lib/request'

describe Request do
  let(:request_id) { 0x1234 }
  let(:request_type) { 'A' }
  let(:server) { '205.251.197.243' }
  let(:domain) { 'powershop.co.nz' }
  subject(:request) { Request.new(domain: domain, server: server, request_type: request_type, request_id: request_id) }

  describe '#pack' do
    subject { request.pack }
    let(:expected_id) { [request_id].pack('n') }
    let(:expected_flags) { [0].pack('n') }
    let(:expected_questions_count) { [1].pack('n') }
    let(:expected_answers_count) { [0].pack('n') }
    let(:expected_authority_rrs_count) { [0].pack('n') }
    let(:expected_additional_rrs_count) { [0].pack('n') }
    let(:domain_octet_1) { 'powershop'}
    let(:packed_domain_octet_1) { [domain_octet_1].pack('a*') }
    let(:packed_octet_length_1) { [domain_octet_1.length].pack('C') }
    let(:domain_octet_2) { 'co'}
    let(:packed_domain_octet_2) { [domain_octet_2].pack('a*') }
    let(:packed_octet_length_2) { [domain_octet_2.length].pack('C') }
    let(:domain_octet_3) { 'nz'}
    let(:packed_domain_octet_3) { [domain_octet_3].pack('a*') }
    let(:packed_octet_length_3) { [domain_octet_3.length].pack('C') }
    let(:terminating_null) { [0].pack('C') }
    let(:packed_request_type) { [1].pack('n') }
    let(:packed_request_class) { [1].pack('n') }
    let(:expected_packet) {
      expected_id +
      expected_flags +
      expected_questions_count +
      expected_answers_count +
      expected_authority_rrs_count +
      expected_additional_rrs_count +
      packed_octet_length_1 +
      packed_domain_octet_1 +
      packed_octet_length_2 +
      packed_domain_octet_2 +
      packed_octet_length_3 +
      packed_domain_octet_3 +
      terminating_null +
      packed_request_type +
      packed_request_class
    }

    it { is_expected.to eq (expected_packet) }
  end
end
