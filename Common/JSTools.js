function getHTMLElementAtPoint(x,y) {
    var tags = "";
    var e = document.elementFromPoint(x,y);
    if (e.tagName == 'IMG') {
        tags += e.getAttribute('src');
    }
    tags += ",";
    tags += e.width;
    
    tags += ",";
    tags += e.height;
    
    tags += ",";
    tags += e.getBoundingClientRect().left;
    
    tags += ",";
    tags += e.getBoundingClientRect().top;
    
    return tags;
}

