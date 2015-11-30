require 'spec_helper'
require './lib/resource_record'

describe ResourceRecord do
  describe '.unpack' do
    let(:packed_response) { "\x124\x84\x00\x00\x01\x00\x01\x00\x04\x00\x00\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00".force_encoding('ASCII-8BIT') }
    let(:packed_stream) { StringIO.new(packed_response) }
    let(:resource_record) { ResourceRecord.unpack(packed_stream, packed_response) }
    let(:packed_ip_address) { '203.171.34.211'.split('.').map(&:to_i).pack('cccc') }

    before do
      packed_stream.seek(33)
    end

    it 'unpacks correctly' do
      expect(resource_record.name.to_s).to eq('powershop.co.nz')
      expect(resource_record.rdata).to eq(packed_ip_address)
      expect(packed_stream.tell).to eq(49)
    end
  end
end
