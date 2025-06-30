require 'rails_helper'

RSpec.describe 'プロジェクトのSJIS文字検証', type: :feature do
  let(:admin_user) { create(:user, :administrator) }

  before do
    login_as(admin_user, scope: :user)
  end

  describe 'プロジェクト新規作成' do
    before do
      visit new_project_path
    end

    context 'SJIS変換できない文字を含む場合' do
      it '絵文字を含むプロジェクト名でエラーが表示される' do
        fill_in 'project_code', with: '2401'
        fill_in 'project_name', with: 'テストプロジェクト😀'
        fill_in 'project_name_reading', with: 'てすとぷろじぇくと'
        
        click_button '登録'
        
        expect(page).to have_content('新規プロジェクトの作成に失敗しました。')
        expect(page).to have_content('名前 に Shift_JIS に変換できない文字「😀」が含まれています')
        expect(current_path).to eq(projects_path)
      end

      it 'Unicode特有の記号を含むプロジェクト名でエラーが表示される' do
        fill_in 'コード', with: '2401'
        fill_in '名前', with: 'プロジェクト№2024'
        fill_in 'よみ(かな)', with: 'ぷろじぇくと'
        
        click_button '登録'
        
        expect(page).to have_content('新規プロジェクトの作成に失敗しました。')
        expect(page).to have_content('Shift_JIS に変換できない文字')
      end
    end

    context 'SJIS変換可能な文字のみの場合' do
      it '日本語のプロジェクト名で正常に作成される' do
        fill_in 'コード', with: '2401'
        fill_in '名前', with: '新規プロジェクト（２０２４年度）'
        fill_in 'よみ(かな)', with: 'しんきぷろじぇくと'
        
        click_button '登録'
        
        expect(page).to have_content('新規プロジェクトを作成しました。')
        expect(current_path).to eq(projects_path)
        expect(page).to have_content('新規プロジェクト（２０２４年度）')
      end

      it '英数字のプロジェクト名で正常に作成される' do
        fill_in 'コード', with: '2402'
        fill_in '名前', with: 'Web Development Project 2024'
        fill_in 'よみ(かな)', with: 'うぇぶでべろっぷめんと'
        
        click_button '登録'
        
        expect(page).to have_content('新規プロジェクトを作成しました。')
        expect(page).to have_content('Web Development Project 2024')
      end
    end
  end

  describe 'プロジェクト編集' do
    let!(:project) { create(:project, name: '既存プロジェクト', code: 2301) }

    before do
      visit edit_project_path(project)
    end

    context 'SJIS変換できない文字を含む場合' do
      it '絵文字を追加するとエラーが表示される' do
        fill_in '名前', with: '既存プロジェクト😊更新'
        
        click_button '更新'
        
        expect(page).to have_content('プロジェクトの設定の更新に失敗しました。')
        expect(page).to have_content('Shift_JIS に変換できない文字「😊」が含まれています')
      end
    end

    context 'SJIS変換可能な文字のみの場合' do
      it '正常に更新される' do
        fill_in '名前', with: '既存プロジェクト【更新版】'
        
        click_button '更新'
        
        expect(page).to have_content('プロジェクトの設定を更新しました。')
        expect(page).to have_content('既存プロジェクト【更新版】')
      end
    end
  end

  describe 'CSVエクスポート' do
    context 'すべてのプロジェクトがSJIS変換可能な場合' do
      let!(:project1) { create(:project, name: 'プロジェクトA', code: 2401) }
      let!(:project2) { create(:project, name: 'プロジェクトB（２０２４）', code: 2402) }

      it '正常にCSVがダウンロードされる' do
        visit admin_csvs_path
        
        within('form[action*="/projects.csv"]') do
          click_button 'ダウンロード'
        end
        
        # CSVダウンロードが成功することを確認
        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include('project_')
      end
    end
  end
end