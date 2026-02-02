import { Page, Locator } from '@playwright/test';

export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async navigate(path: string) {
    await this.page.goto(path);
  }

  async waitForReactComponent(selector: string, timeout: number = 30000) {
    // Reactコンポーネントが読み込まれるまで待機
    await this.page.waitForSelector(selector, { timeout });
    // Reactの初期化が完了するまで少し待機
    await this.page.waitForTimeout(500);
  }

  async screenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png`, fullPage: true });
  }
}