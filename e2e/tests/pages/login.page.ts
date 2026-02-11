import { Page, Locator } from '@playwright/test';
import { BasePage } from './base.page';

export class LoginPage extends BasePage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.locator('input[name="user[email]"]');
    this.passwordInput = page.locator('input[name="user[password]"]');
    this.submitButton = page.locator('input[type="submit"][value="ログイン"]');
  }

  async login(email: string, password: string) {
    await this.navigate('/users/sign_in');
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
    // ログイン後のリダイレクトを待つ
    await this.page.waitForURL('**/reports', { timeout: 10000 });
  }
}