require 'spec_helper'
require './lib/response'

describe Response do
  let(:packed_response) { "\x124\x84\x00\x00\x01\x00\x01\x00\x04\x00\x00\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00".force_encoding('ASCII-8BIT') }

  describe '.unpack' do
    subject(:response) { Response.unpack(packed_response) }

    it 'unpacks correctly' do
      expect(response.request_id).to eq(0x1234)
      expect(response.questions.length).to eq(1)
      expect(response.questions.first).to eq('powershop.co.nz')
      expect(response.answers.length).to eq(1)
      expect(response.answers.first.to_s).to eq('203.171.34.211')
    end
  end
end
