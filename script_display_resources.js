function displayResourcesId() {
    var rows = document.querySelectorAll("div[class^='x-grid3-row']:not([data-resId])")

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
            // Get elements of row children who have x-tree3-node-text class
            if (!row.getAttributeNames().includes('data-resId')) {
                row.setAttribute('data-resId', resID);
            }
        }
    }
}

document.getElementsByClassName('x-grid3-scroller')[0].onscroll = function() {
    displayResourcesId();
}