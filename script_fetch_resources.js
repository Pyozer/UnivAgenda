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

function parseHTML() {
    var rows = document.querySelectorAll('div[class^="treeline"]');

    var element = new Tree();

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];

        var textContent = row.textContent.split('\n')[0];
        var level = textContent.split('   ').length;
        console.log(textContent + ":" + level);

        var resDivs = row.getElementsByTagName('span');
        var resDiv = null;
        if (resDivs.length > 1)
            resDiv = resDivs[1];
        else if (resDivs.length == 1) // If category (ex: Trainee)
            resDiv = resDivs[0];

        var resID = -1;
        var spanText = "null";

        if (resDiv != null) {
            resID = resDiv.getElementsByTagName('a')[0].getAttribute("href").replace(/\D/g, "");
            spanText = resDiv.getElementsByTagName('a')[0].textContent;
        }
        pushToLevel(element, new Node(spanText, resID), 1, level);
    }

    function pushToLevel(element, valueToPush, actualLevel, levelTarget) {
        if (element.children == null) {
            element.children = [];
        }
        let level = element.children.length - 1;
        if (actualLevel == levelTarget)
            element.children.push(valueToPush);
        else {
            pushToLevel(element.children[level < 0 ? 0 : level], valueToPush, actualLevel + 1, levelTarget);
        }
    }

    var json = element.toString().replace(/,\}/g, '}').replace(/\}\}/g, '}}');
    console.log(json);
}