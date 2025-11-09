// Copyright (c) 2019 Samarjeet

window.onload = function () {
  const $searchbar = document.getElementById("searchbar");
  const $searchResults = document.getElementById("search-results");

  if (!$searchbar || !$searchResults) return;

  // eslint-disable-next-line no-undef
  SimpleJekyllSearch({
    searchInput: $searchbar,
    resultsContainer: $searchResults,
    json: '{{ "/search.json" | relative_url }}',
    // SimpleJekyllSearch doesn't use string template literals.
    // eslint-disable-next-line github/unescaped-html-literal
    searchResultTemplate: '<a href="{url}" target="_blank">{title}</a>',
    noResultsText: "",
  });

  /* hack ios safari unfocus */
  if (/Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent))
    document.body.firstElementChild.tabIndex = 1;

  const $labelGroup = document.querySelector(".posts-labelgroup");
  const $postLabel = document.getElementById("posts-label");
  const labelWidth = $postLabel.scrollWidth;

  $postLabel.style.width = `${labelWidth}px`;

  $labelGroup.addEventListener(
    "click",
    function (e) {
      $searchResults.style.display = null;
      $postLabel.style.width = "0";
      $labelGroup.setAttribute("class", "posts-labelgroup focus-within");
      $searchbar.focus();
      e.stopPropagation();
    },
    false,
  );

  $labelGroup.addEventListener("mouseleave", function () {
    document.body.onclick = searchCollapse;
  });

  function searchCollapse() {
    $searchResults.style.display = "none";
    $labelGroup.setAttribute("class", "posts-labelgroup");
    $postLabel.style.width = `${labelWidth}px`;
    document.body.onclick = null;
  }
};
