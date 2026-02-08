// Adapted from https://github.com/jswanner/DontF-WithPaste

const events = ["copy", "cut", "paste"];
events.forEach((s) => {
  document.addEventListener(s, (e) => {
    e.stopImmediatePropagation();
  });
});
