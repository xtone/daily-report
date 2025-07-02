require 'rails_helper'

RSpec.describe SjisConvertibleValidator do
  # テスト用のモデルクラスを定義
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :name

      validates :name, sjis_convertible: true

      def self.name
        'TestModel'
      end
    end
  end

  let(:model) { model_class.new }

  describe 'SJIS変換可能文字のバリデーション' do
    context '正常な文字列の場合' do
      it '日本語（ひらがな、カタカナ、漢字）を含む文字列は有効' do
        model.name = '新規プロジェクト'
        expect(model).to be_valid

        model.name = 'テストプロジェクト'
        expect(model).to be_valid

        model.name = 'ひらがなプロジェクト'
        expect(model).to be_valid
      end

      it 'ASCII文字のみの文字列は有効' do
        model.name = 'New Project 123'
        expect(model).to be_valid
      end

      it 'JIS第1水準・第2水準の漢字は有効' do
        model.name = '高橋プロジェクト' # 通常の「高」
        expect(model).to be_valid
        
        model.name = '齋藤プロジェクト' # 「齋」はJIS第2水準
        expect(model).to be_valid
      end

      it '全角記号を含む文字列は有効' do
        model.name = 'プロジェクト（２０２４年度）'
        expect(model).to be_valid
      end
    end

    context '異常な文字列の場合' do
      it '絵文字を含む文字列は無効' do
        model.name = 'プロジェクト😀'
        expect(model).not_to be_valid
        expect(model.errors[:name]).to include(/Shift_JIS に変換できない文字「😀」が含まれています/)
      end

      it 'Unicode特有の記号を含む文字列は無効' do
        model.name = 'プロジェクト♠♣♥♦'
        expect(model).not_to be_valid
        expect(model.errors[:name]).to include(/Shift_JIS に変換できない文字/)
      end

      it '中国語簡体字を含む文字列は無効' do
        model.name = '项目管理' # 中国語簡体字
        expect(model).not_to be_valid
        expect(model.errors[:name]).to include(/Shift_JIS に変換できない文字/)
      end

      it 'ハングル文字を含む文字列は無効' do
        model.name = '프로젝트' # 韓国語
        expect(model).not_to be_valid
        expect(model.errors[:name]).to include(/Shift_JIS に変換できない文字/)
      end

      it '特殊な Unicode 文字を含む文字列は無効' do
        model.name = 'プロジェクト№' # 「№」はSJISに存在しない
        expect(model).not_to be_valid
        expect(model.errors[:name]).to include(/Shift_JIS に変換できない文字/)
      end
    end

    context '空文字列の場合' do
      it '空文字列は検証をスキップする' do
        model.name = ''
        # sjis_convertible バリデーション自体はパスするが、
        # 実際のモデルでは presence: true があるため無効になる
        model.valid?
        expect(model.errors[:name]).not_to include(/Shift_JIS に変換できない文字/)
      end

      it 'nilは検証をスキップする' do
        model.name = nil
        model.valid?
        expect(model.errors[:name]).not_to include(/Shift_JIS に変換できない文字/)
      end
    end
  end

  describe 'カスタムメッセージ' do
    let(:model_class_with_custom_message) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Validations

        attr_accessor :name

        validates :name, sjis_convertible: { message: 'には使用できない文字が含まれています' }

        def self.name
          'TestModelWithCustomMessage'
        end
      end
    end

    let(:model) { model_class_with_custom_message.new }

    it 'カスタムメッセージが表示される' do
      model.name = 'プロジェクト😀'
      expect(model).not_to be_valid
      expect(model.errors[:name]).to include('には使用できない文字が含まれています')
    end
  end
end