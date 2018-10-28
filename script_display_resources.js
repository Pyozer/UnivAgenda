function displayResourcesId() {
    var rows = document.querySelectorAll("div[class^='x-grid3-row']:not([data-resname]):not([data-resid])")

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
            var nameElem = rowNode.getElementsByClassName('x-tree3-node-text')[0];
            row.setAttribute('data-resid', resID);
            row.setAttribute('data-resname', nameElem.innerHTML.replace(/"/g, '').replace(/\s\s+/g, ' '));
        }
    }
}

document.getElementsByClassName('x-grid3-scroller')[0].onscroll = function() {
    displayResourcesId();
}