function removePylodeToc (documentRef) {
    var documentRef = documentRef || document
    var toc = documentRef.body.querySelector('#pylode + #toc')
    if (toc) {
        toc.remove()
    }
}
function htmlTableOfContents (documentRef) {
    var documentRef = documentRef || document;
    var toc = documentRef.getElementById('toc');
    var headings = [].slice.call(documentRef.body.querySelectorAll('h2, h3, h4, h5, h6'));
    headings.forEach(function (heading, index) {
        if (heading.classList.contains('notoc')) {
            return;
        }
        var anchor = documentRef.createElement('a');
        anchor.setAttribute('name', 'toc' + index);
        anchor.setAttribute('id', 'toc' + index);
        
        var link = documentRef.createElement('a');
        link.setAttribute('href', '#toc' + index);
        heading.childNodes.forEach((child) => {
            link.appendChild(child.cloneNode())
        })
        // link.textContent = heading.textContent;
        
        var div = documentRef.createElement('div');
        div.setAttribute('class', heading.tagName.toLowerCase());
        
        div.appendChild(link);
        toc.appendChild(div);
        heading.parentNode.insertBefore(anchor, heading);
    });
}


window.addEventListener("load", () => {
    removePylodeToc()
    htmlTableOfContents()
})