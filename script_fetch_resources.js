class Tree {
    constructor(children = []) {
        this.children = children;
    }
}

Tree.prototype.toString = function treeToString() {
    var elemsStr = '';
    this.children.forEach(function (elem) {
        elemsStr += elem.toString();
    });
    return "{" + elemsStr + "}";
}

class Node {
    constructor(label, resID, children = []) {
        this.label = label;
        this.resID = resID;
        this.children = children;
    }
}

Node.prototype.toString = function nodeToString() {
    if (this.children.length < 1)
        return "\"" + this.label + "\": " + this.resID + ",";
    else {
        var elemsStr = '';
        this.children.forEach(function (elem) {
            elemsStr += elem.toString();
        });
        return "\"" + this.label + "\": {" + elemsStr + "},";
    }
}

function pushToLevel(element, valueToPush, actualLevel, levelTarget) {
    if (element.children == null) {
        element.children = [];
    }
    let level = element.children.length - 1;
    let next = element.children[level];
    if (actualLevel == levelTarget)
        element.children.push(valueToPush);
    else if (next != null) {
        pushToLevel(element.children[level], valueToPush, actualLevel + 1, levelTarget);
    }
}

function parseHTML() {
    var rows = document.querySelectorAll('div[class^="x-grid3-row"]');

    var element = new Tree();

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];

        var level = row.getAttribute('aria-level');
        var resID = row.getAttribute('data-resid');
        var resName = row.getAttribute('data-resname').replace(/"/g, "");
        if (resID == null)
            resID = -1;
        if (resName == null)
            resName = "null";

        pushToLevel(element, new Node(resName, resID), 1, level);
    }

    var json = element.toString().replace(/,\}/g, '}').replace(/\}\}/g, '}}');
    console.log(json);
}