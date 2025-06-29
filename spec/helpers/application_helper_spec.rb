require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#title' do
    context 'content_for(:title)が設定されている場合' do
      before do
        helper.content_for(:title, 'カスタムタイトル')
      end

      it 'カスタムタイトルとサイト名を組み合わせて返す' do
        expect(helper.title).to eq("カスタムタイトル | #{I18n.t(:site_name)}")
      end
    end

    context 'content_for(:title)が設定されていない場合' do
      before do
        allow(helper).to receive(:controller_path).and_return('reports')
        allow(helper).to receive(:action_name).and_return('index')
      end

      context '対応するI18nキーが存在しない場合' do
        it 'サイト名のみを返す' do
          expect(helper.title).to eq(I18n.t(:site_name))
        end
      end
    end
  end

  describe '#error_message' do
    let(:user) { build(:user, name: '', email: '') }

    before do
      user.valid? # バリデーションエラーを発生させる
    end

    context '指定した属性にエラーがある場合' do
      it 'エラーメッセージを含むdivタグを返す' do
        result = helper.error_message(user, :name)
        expect(result).to include('alert alert-danger')
        expect(result).to include('ユーザー名を入力してください')
      end
    end

    context '指定した属性にエラーがない場合' do
      it 'nilを返す' do
        valid_user = build(:user, email: 'valid@example.com')
        valid_user.valid?
        expect(helper.error_message(valid_user, :name)).to be_nil
      end
    end
  end

  describe '#render_flash_message' do
    context 'alertメッセージがある場合' do
      before { flash[:alert] = 'エラーメッセージ' }

      it 'alert用のdivタグを返す' do
        result = helper.render_flash_message
        expect(result).to include('alert alert-danger')
        expect(result).to include('エラーメッセージ')
      end
    end

    context 'noticeメッセージがある場合' do
      before { flash[:notice] = '成功メッセージ' }

      it 'notice用のdivタグを返す' do
        result = helper.render_flash_message
        expect(result).to include('alert alert-success')
        expect(result).to include('成功メッセージ')
      end
    end

    context '両方のメッセージがある場合' do
      before do
        flash[:alert] = 'エラーメッセージ'
        flash[:notice] = '成功メッセージ'
      end

      it '両方のdivタグを返す' do
        result = helper.render_flash_message
        expect(result).to include('alert alert-danger')
        expect(result).to include('alert alert-success')
        expect(result).to include('エラーメッセージ')
        expect(result).to include('成功メッセージ')
      end
    end

    context 'メッセージがない場合' do
      it '空の内容を返す' do
        result = helper.render_flash_message
        expect(result).to be_blank
      end
    end
  end

  describe '#global_header' do
    context 'ユーザーがログインしている場合' do
      let(:user) { create(:user, email: 'header_test@example.com') }

      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:navbar).and_return('<nav>navbar</nav>'.html_safe)
        allow(helper).to receive(:signout_form).and_return('<form>signout</form>'.html_safe)
      end

      it 'navbarとsignout_formを含むHTMLを返す' do
        result = helper.global_header
        expect(result).to include('<nav>navbar</nav>')
        expect(result).to include('<form>signout</form>')
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'nilを返す' do
        expect(helper.global_header).to be_nil
      end
    end
  end

  describe '#navbar' do
    let(:user) { create(:user, email: 'navbar_test@example.com') }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_page?).and_return(false)
    end

    it 'ナビゲーションメニューを含むulタグを返す' do
      result = helper.navbar
      expect(result).to include('nav navbar-nav')
      expect(result).to include('日報入力')
      expect(result).to include('プロジェクト設定')
      expect(result).to include('パスワード変更')
    end

    context 'ユーザーが管理者権限を持つ場合' do
      let(:admin_user) { create(:user, :administrator, email: 'admin_navbar@example.com') }

      before do
        allow(helper).to receive(:current_user).and_return(admin_user)
      end

      it '管理画面へのリンクが含まれる' do
        result = helper.navbar
        expect(result).to include('管理画面')
      end
    end

    context '現在のページがrootの場合' do
      before do
        allow(helper).to receive(:current_page?).with(root_path).and_return(true)
      end

      it 'activeクラスが設定される' do
        result = helper.navbar
        expect(result).to include('class="active"')
      end
    end
  end

  describe '#signout_form' do
    it 'ログアウト用のフォームを返す' do
      result = helper.signout_form
      expect(result).to include('navbar-form navbar-right')
      expect(result).to include('ログアウト')
      expect(result).to include('btn btn-default')
    end
  end

  describe '#date_select_ja' do
    it '日本語形式の日付選択フィールドを返す' do
      result = helper.date_select_ja(:user, :began_on)
      expect(result).to include('年')
      expect(result).to include('月')
      expect(result).to include('日')
      expect(result).to include('form-control')
    end

    it 'カスタムオプションを適用できる' do
      result = helper.date_select_ja(:user, :began_on, { start_year: 2020 }, { class: 'custom-class' })
      expect(result).to include('custom-class')
    end
  end

  describe '#text_with_ruby' do
    it 'ルビ付きテキストのHTMLを返す' do
      result = helper.text_with_ruby('漢字', 'かんじ')
      expect(result).to include('<ruby>')
      expect(result).to include('漢字')
      expect(result).to include('<rt>かんじ</rt>')
      expect(result).to include('</ruby>')
    end
  end
end
