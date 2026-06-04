require_relative '../lib/books'

describe Book do
  describe '#initialize' do
    context 'when the book is of 2' do
      let(:book) { Book.new('2') }
      it 'has a rank' do
        expect(book.rank).to eq '2'
      end
      it 'has a value' do
        expect(book.value).to eq 0
      end
    end
    context 'when the book is of A' do
      let(:book) { Book.new('A') }
      it 'has a rank' do
        expect(book.rank).to eq 'A'
      end
      it 'has a value' do
        expect(book.value).to eq 12
      end
    end
  end
  describe '#value_of_rank' do
    let(:book) { described_class.new('A') }
    it 'returns 12' do
      expect(book.value_of_rank).to eq 12
    end
  end
end
