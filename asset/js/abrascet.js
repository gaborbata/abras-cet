/*! Abras Cet, Copyright 2025 Gabor Bata */

// navigation toggle for mobile view
(function () {
  var navigationToggle = document.getElementById("navigation-toggle");
  var navigationList = document.getElementById("navigation-list");

  // based on: https://www.quirksmode.org/dom/getstyles.html#link7
  function getDisplayStyle(element) {
    var displayStyle;
    if (element.currentStyle) {
      displayStyle = element.currentStyle.display;
    } else if (window.getComputedStyle) {
      displayStyle = window.getComputedStyle(element, null).getPropertyValue("display");
    }
    return displayStyle;
  }

  function navigationToggleHandler(event) {
    event.preventDefault();
    if (getDisplayStyle(navigationList) === "none") {
      navigationList.style.display = "block";
    } else {
      navigationList.style.display = "none";
    }
  }

  function navigationResizeHandler() {
    if (getDisplayStyle(navigationToggle) === "none") {
      navigationList.style.display = "block";
    } else {
      navigationList.style.display = "none";
    }
  }

  if (!!navigationToggle) {
    navigationToggle.addEventListener("click", navigationToggleHandler);
  }
  if (!!navigationList) {
    window.addEventListener("resize", navigationResizeHandler);
  }
})();

// keyboard navigation
(function () {
  var pagination = document.getElementsByClassName('pagination');
  pagination = pagination.length > 0 ? pagination[0] : null;

  function navigateWithButton(idx) {
    var href = pagination.getElementsByClassName('button')[idx].href;
    if (!!href) {
      window.location = href;
    }
  }

  document.onkeydown = function (evt) {
    if (!pagination || evt.target.nodeName == 'INPUT' || evt.altKey || evt.shiftKey || evt.ctrlKey || evt.metaKey) {
      return;
    } else if (evt.key == 'ArrowLeft') {
      navigateWithButton(1);
    } else if (evt.key == 'ArrowRight') {
      navigateWithButton(2);
    }
  };
})();

// cookie consent
(function () {
  var consentStatus = window.localStorage.getItem("consent.status");
  if (consentStatus != "1") {
    var footer = document.getElementsByTagName("footer");
    footer = footer.length > 0 ? footer[0] : null;
    if (!!footer) {
      var message = "Az oldalon történő látogatása során cookie-kat használunk, melyek információkat szolgáltatnak számunkra a felhasználó oldallátogatási szokásairól, de nem tárolnak személyes információkat. Az oldalon történő továbblépéssel elfogadja a cookie-k használatát.";
      var consentContainer = document.createElement("div");
      consentContainer.style.cssText = "margin:.4em;padding:.9em;max-width:24em;position:fixed;bottom:0;right:0;overflow:hidden;color:#ffffff;background:#252e39;z-index:9999;";
      consentContainer.innerHTML = '<!--googleoff: all--><div>' + message + '</div><a id="consent-close" class="button" style="margin:1em 0 0 0;width:100%;" href="#">Bezár</a> <!--googleon: all-->';
      footer.appendChild(consentContainer);
      document.getElementById("consent-close").addEventListener("click", function (event) {
        event.preventDefault();
        window.localStorage.setItem("consent.status", "1");
        footer.removeChild(consentContainer);
      });
    }
  }
})();
