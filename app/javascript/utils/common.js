// 共通ユーティリティ関数

// CSRFトークンを取得
export const getCsrfToken = () => {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute('content') : null;
};

// Turboイベントリスナーのヘルパー
export const onTurboLoad = (callback) => {
  document.addEventListener('turbo:load', callback);
};

export const onTurboBeforeRender = (callback) => {
  document.addEventListener('turbo:before-render', callback);
};

// React コンポーネントのマウント/アンマウントヘルパー
export const mountComponent = (component, container) => {
  const ReactDOM = require('react-dom');
  ReactDOM.render(component, container);
};

export const unmountComponent = (container) => {
  const ReactDOM = require('react-dom');
  ReactDOM.unmountComponentAtNode(container);
};

// DOM要素の作成ヘルパー
export const createContainer = (id = null) => {
  const container = document.createElement('div');
  if (id) {
    container.id = id;
  }
  return container;
}; 