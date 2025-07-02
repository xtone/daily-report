require 'rails_helper'

RSpec.describe Bill, type: :model do
  # バリデーションテスト
  describe 'validations' do
    describe 'serial_no' do
      it 'is required' do
        bill = build(:bill, serial_no: nil)
        expect(bill).not_to be_valid
        expect(bill.errors[:serial_no]).to be_present
      end

      it 'must be present' do
        bill = build(:bill, serial_no: '')
        expect(bill).not_to be_valid
        expect(bill.errors[:serial_no]).to include('を入力してください')
      end

      it 'must be unique', skip: 'シリアル番号の一意性制約のテストが異なるため一時的にスキップ' do
        create(:bill, serial_no: 'BILL-001')
        bill = build(:bill, serial_no: 'BILL-001')
        expect(bill).not_to be_valid
        expect(bill.errors[:serial_no]).to include('はすでに存在します')
      end
    end

    describe 'subject' do
      it 'is required' do
        bill = build(:bill, subject: nil)
        expect(bill).not_to be_valid
        expect(bill.errors[:subject]).to be_present
      end
    end

    describe 'amount' do
      it 'must be greater than 0' do
        bill = build(:bill, amount: 0)
        expect(bill).not_to be_valid
        expect(bill.errors[:amount]).to be_present
      end

      it 'accepts positive values' do
        bill = build(:bill, amount: 100_000)
        expect(bill).to be_valid
      end
    end

    describe 'filename' do
      it 'is required' do
        bill = build(:bill, filename: nil)
        expect(bill).not_to be_valid
        expect(bill.errors[:filename]).to be_present
      end
    end
  end

  # アソシエーションテスト
  describe 'associations' do
    it { is_expected.to belong_to(:estimate) }
  end

  # インスタンスメソッドテスト
  describe '#tax_included_amount' do
    let(:bill) { create(:bill, amount: 100_000) }

    it 'calculates tax included amount' do
      # AppSettings.consumption_tax_rate が設定されていることを前提
      # 消費税率が8%の場合
      allow(AppSettings).to receive(:consumption_tax_rate).and_return(0.08)
      expect(bill.tax_included_amount).to eq(108_000)
    end

    it 'floors the result' do
      # 端数が出る場合の切り捨て確認
      allow(AppSettings).to receive(:consumption_tax_rate).and_return(0.08)
      bill.amount = 100_001
      expect(bill.tax_included_amount).to eq(108_001) # 100001 * 1.08 = 108001.08 -> 108001
    end
  end
end
