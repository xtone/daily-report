import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { ReportsPage } from './pages/reports.page';

test.describe('React Components Display Tests', () => {
  let loginPage: LoginPage;
  let reportsPage: ReportsPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    reportsPage = new ReportsPage(page);
  });

  test('日報画面のReactコンポーネントが正しく表示される', async ({ page }) => {
    // テスト用のログイン情報（実際の環境に合わせて変更してください）
    await loginPage.login('test@example.com', 'password');
    
    // 日報画面に遷移
    await reportsPage.navigate();
    
    // Reactコンポーネントが読み込まれたか確認
    const isLoaded = await reportsPage.isReactComponentLoaded();
    expect(isLoaded).toBeTruthy();
    
    // スクリーンショットを撮影
    await page.screenshot({ path: 'screenshots/reports-page.png', fullPage: true });
  });

  test('プロジェクト一覧画面のReactコンポーネントが表示される', async ({ page }) => {
    await loginPage.login('test@example.com', 'password');
    
    await page.goto('/settings/projects');
    await page.waitForSelector('#project_list', { timeout: 30000 });
    
    const projectList = page.locator('#project_list');
    await expect(projectList).toBeVisible();
    
    await page.screenshot({ path: 'screenshots/projects-page.png', fullPage: true });
  });

  test('管理画面のReactコンポーネントが表示される', async ({ page }) => {
    await loginPage.login('admin@example.com', 'password');
    
    await page.goto('/admin/csvs');
    
    // Reactコンポーネントの存在確認
    const datePickers = page.locator('.react-date-picker');
    const count = await datePickers.count();
    
    // 日付ピッカーが存在することを確認
    expect(count).toBeGreaterThan(0);
    
    await page.screenshot({ path: 'screenshots/admin-page.png', fullPage: true });
  });
});