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

function setDarkMode() {
  const DARK_CLASS = "dark";
  var body = document.querySelector("body");

  if (window.matchMedia?.("(prefers-color-scheme: dark)")?.matches) {
    body.classList.add(DARK_CLASS);
  } else {
    body.classList.remove(DARK_CLASS);
  }
}

// Attempt both requestAnimationFrame and DOMContentLoaded, whichever comes
// first.
if (window.requestAnimationFrame) {
  window.requestAnimationFrame(setDarkMode);
}
window.addEventListener("DOMContentLoaded", setDarkMode);

// Watch for changes to the preferred color scheme.
window
  .matchMedia("(prefers-color-scheme: dark)")
  .addEventListener("change", setDarkMode);
