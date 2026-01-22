class Hunter {
  constructor(name, urlRegex, selectorString, index) {
    this.name = name;
    this.urlRegex = urlRegex;
    this.selectorString = selectorString;
    this.index = index;
  }
}

const hunters = [
  new Hunter(
    "Tai",
    /^https:\/\/labs.cognitiveclass.ai\/v2\/tools\/jupyterlab/,
    "nav>ul>li.relative",
    0,
  ),

  new Hunter(
    "Copilot in Outlook",
    /^https:\/\/outlook.office.com\/mail\/.*/,
    "#CopilotCommandCenterButton",
    0,
  ),

  new Hunter(
    "Coach on Coursera",
    /^https:\/\/www.coursera.org\/learn\/.*\/assignment-submission\/.*\/.*/,
    'div[data-testid="page-body"]>div',
    0,
  ),
];

for (const hunter of hunters) {
  if (window.document.URL.match(hunter.urlRegex)) {
    console.log(`Initiating ${hunter.name} elimination protocol...`);
    window.addEventListener("load", () => {
      const intervalId = setInterval(() => {
        const elements = document.querySelectorAll(hunter.selectorString);

        if (elements.length > hunter.index) {
          clearInterval(intervalId); // stop searching
          elements[hunter.index].style.display = "none"; // hide the element
        }
      }, 1000);
    });
  }
}
