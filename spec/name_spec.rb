require 'spec_helper'
require './lib/name'
require 'stringio'

describe Name do
  describe '.unpack' do
    let(:packed_response) { "\x124\x84\x00\x00\x01\x00\x01\x00\x04\x00\x00\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00".force_encoding('ASCII-8BIT') }
    let(:packed_name) { StringIO.new(packed_response) }

    context 'with a non-compressed name' do
      let(:packed_length) { 17 }
      let(:unpacked_name) { 'powershop.co.nz' }
      let(:offset) { 12 }
      let(:packed_name_only) { "\tpowershop\x02co\x02nz\x00".force_encoding('ASCII-8BIT') }
      let(:name) { Name.unpack(packed_name, packed_response) }

      before do
        packed_name.seek(offset)
      end

      it 'unpacks the name' do
        expect(name.to_s).to eq(unpacked_name)
        expect(packed_name.tell).to eq(offset + packed_length)
      end

      it 'packs to itself' do
        expect(name.pack).to eq(packed_name_only)
      end
    end

    context 'with a compressed name' do
      let(:packed_length) { 2 }
      let(:unpacked_name) { 'powershop.co.nz' }
      let(:offset) { 33 }
      let(:name) { Name.unpack(packed_name, packed_response) }

      before do
        packed_name.seek(offset)
      end

      it 'unpacks the name' do
        expect(name.to_s).to eq(unpacked_name)
        expect(packed_name.tell).to eq(offset + packed_length)
      end
    end
  end
end
