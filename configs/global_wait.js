module.exports = function (phantom, ready) {
    // make Wraith wait a bit longer before taking the screenshot​
    setTimeout(ready, 4000); // you MUST call the ready() callback for Wraith to continue​
}
