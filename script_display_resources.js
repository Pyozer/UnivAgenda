function displayResourcesId() {
    var rows = document.querySelectorAll("div[class^='x-grid3-row']:not([data-resName])")

    // For each row
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        
        // Check if row contains resources data
        var rowNodes = row.getElementsByClassName('x-tree3-node');
        if (rowNodes.length > 0) {
            // Get row data element
            var rowNode = rowNodes[0];
            // Get resource id from id attribute
            var resID = rowNode.getAttribute('id').replace('Direct Planning Tree_', '');
            var resName = rowNode.getElementsByClassName('x-tree3-node-text')[0].innerHTML;
            row.setAttribute('data-resId', resID);
            row.setAttribute('data-resName', resName);
        }
    }
}

document.getElementsByClassName('x-grid3-scroller')[0].onscroll = function() {
    displayResourcesId();
}