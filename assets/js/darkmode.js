// Copyright (c) 2019 Samarjeet
// Copyright 2025 Ian Lewis
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const DARK_CLASS = "dark";
const THEME_STORAGE_KEY = "theme-preference";
const THEMES = {
  LIGHT: "light",
  DARK: "dark",
  AUTO: "auto",
};

function getStoredTheme() {
  return localStorage.getItem(THEME_STORAGE_KEY) || THEMES.AUTO;
}

function setStoredTheme(theme) {
  localStorage.setItem(THEME_STORAGE_KEY, theme);
}

function getSystemTheme() {
  if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
    return THEMES.DARK;
  }
  return THEMES.LIGHT;
}

function applyTheme(theme) {
  const body = document.querySelector("body");
  const effectiveTheme = theme === THEMES.AUTO ? getSystemTheme() : theme;

  if (effectiveTheme === THEMES.DARK) {
    body.classList.add(DARK_CLASS);
  } else {
    body.classList.remove(DARK_CLASS);
  }
}

function updateThemeToggle(theme) {
  const buttons = document.querySelectorAll(".theme-toggle button");
  for (const button of buttons) {
    if (button.getAttribute("data-theme") === theme) {
      button.classList.add("active");
      button.setAttribute("aria-pressed", "true");
    } else {
      button.classList.remove("active");
      button.setAttribute("aria-pressed", "false");
    }
  }
}

function setTheme(theme) {
  setStoredTheme(theme);
  applyTheme(theme);
  updateThemeToggle(theme);
}

function initializeTheme() {
  const storedTheme = getStoredTheme();
  applyTheme(storedTheme);
  updateThemeToggle(storedTheme);
}

// Initialize theme as early as possible
if (window.requestAnimationFrame) {
  window.requestAnimationFrame(initializeTheme);
}

// Setup theme toggle buttons on DOMContentLoaded
window.addEventListener("DOMContentLoaded", () => {
  initializeTheme();

  const buttons = document.querySelectorAll(".theme-toggle button");
  for (const button of buttons) {
    button.addEventListener("click", () => {
      const theme = button.getAttribute("data-theme");
      setTheme(theme);
    });
  }
});

// Watch for changes to system color scheme when in auto mode
window
  .matchMedia("(prefers-color-scheme: dark)")
  .addEventListener("change", () => {
    const storedTheme = getStoredTheme();
    if (storedTheme === THEMES.AUTO) {
      applyTheme(THEMES.AUTO);
    }
  });
