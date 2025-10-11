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

import { defineConfig } from "html-validate";

export default defineConfig({
  elements: ["html5"],
  extends: ["html-validate:recommended"],
  root: true,
  rules: {
    // DOCTYPE is case-insensitive. prettier-plugin-liquid formats it to
    // lowercase.
    // https://html.spec.whatwg.org/multipage/syntax.html#the-doctype
    "doctype-style": "off",

    // TODO(#320): Don't use inline style in blog posts.
    "no-inline-style": "off",

    // TODO(#315): Enable these rules once the issues are resolved.
    "long-title": "off",
    "no-deprecated-attr": "off",
    "no-trailing-whitespace": "off",
    "unique-landmark": "off",
    "valid-id": "off",
    "void-style": "off",
    "wcag/h30": "off",
    "wcag/h37": "off",
    "wcag/h67": "off",
  },
});
