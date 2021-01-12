import { AppPage } from './app.po';
import { browser, logging } from 'protractor';

describe('workspace-project App', () => {
  let page: AppPage;

  beforeEach(() => {
    page = new AppPage();
  });

  it('should display application title: EventManager', () => {
    page.navigateTo();
    expect(page.getAppTitle()).toEqual('EventManager');
  });
});
