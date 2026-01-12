class Hunter {
  constructor(name, url, selectorString, index) {
    this.name = name;
    this.url = url;
    this.selectorString = selectorString;
    this.index = index;
  }
}

const hunters = [
  new Hunter(
    "Tai",
    "https://labs.cognitiveclass.ai/v2/tools/jupyterlab",
    "nav>ul>li.relative",
    0,
  ),

  new Hunter(
    "Copilot in Outlook",
    "https://outlook.office.com/mail/",
    "#CopilotCommandCenterButton",
    0,
  ),
];

for (const hunter of hunters) {
  if (document.URL.startsWith(hunter.url)) {
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
