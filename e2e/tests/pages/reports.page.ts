import { Page, Locator } from '@playwright/test';
import { BasePage } from './base.page';

export class ReportsPage extends BasePage {
  readonly reactContainer: Locator;
  readonly calendarDays: Locator;
  readonly registerButton: Locator;

  constructor(page: Page) {
    super(page);
    this.reactContainer = page.locator('#reports');
    this.calendarDays = page.locator('.calendar-day');
    this.registerButton = page.locator('button:has-text("登録")');
  }

  async navigate() {
    await super.navigate('/reports');
    await this.waitForReactComponent('#reports');
  }

  async isReactComponentLoaded(): Promise<boolean> {
    try {
      await this.reactContainer.waitFor({ state: 'visible', timeout: 5000 });
      // カレンダーの日付が表示されているか確認
      const dayCount = await this.calendarDays.count();
      return dayCount > 0;
    } catch {
      return false;
    }
  }

  async clickDay(date: string) {
    const dayElement = this.page.locator(`.calendar-day:has-text("${date}")`);
    await dayElement.click();
  }
}