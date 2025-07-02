// Playwright script to capture screenshots of all pages

const playwright = require('playwright');
const fs = require('fs');
const path = require('path');

// Create screenshots directory
const screenshotsDir = path.join(__dirname, 'screenshots');
if (!fs.existsSync(screenshotsDir)) {
  fs.mkdirSync(screenshotsDir);
}

// Pages to capture without authentication
const publicPages = [
  { url: '/users/sign_in', name: 'login' },
  { url: '/users/sign_up', name: 'signup' },
];

// Pages to capture with authentication
const authenticatedPages = [
  { url: '/', name: 'home' },
  { url: '/reports', name: 'reports-index' },
  { url: '/reports/new', name: 'reports-new' },
  { url: '/reports/summary', name: 'reports-summary' },
  { url: '/reports/unsubmitted', name: 'reports-unsubmitted' },
  { url: '/projects', name: 'projects-index' },
  { url: '/projects/new', name: 'projects-new' },
  { url: '/estimates', name: 'estimates-index' },
  { url: '/bills', name: 'bills-index' },
  { url: '/users', name: 'users-index' },
  { url: '/users/new', name: 'users-new' },
  { url: '/settings/projects', name: 'settings-projects' },
  { url: '/settings/password', name: 'settings-password' },
  { url: '/admin', name: 'admin-dashboard' },
  { url: '/admin/csvs', name: 'admin-csvs' },
];

async function captureScreenshots() {
  const browser = await playwright.chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });

  const page = await context.newPage();
  const baseUrl = 'http://localhost:3000';

  console.log('Capturing public pages...');
  
  // Capture public pages
  for (const pageInfo of publicPages) {
    try {
      await page.goto(baseUrl + pageInfo.url);
      await page.waitForLoadState('networkidle');
      await page.screenshot({
        path: path.join(screenshotsDir, `${pageInfo.name}.png`),
        fullPage: true
      });
      console.log(`✓ Captured: ${pageInfo.name}`);
    } catch (error) {
      console.error(`✗ Failed to capture ${pageInfo.name}: ${error.message}`);
    }
  }

  // Note: For authenticated pages, we would need to login first
  // Since we cannot create users due to the encrypted_password issue,
  // we'll skip authenticated pages for now

  await browser.close();
  console.log('Screenshot capture completed!');
}

captureScreenshots().catch(console.error);