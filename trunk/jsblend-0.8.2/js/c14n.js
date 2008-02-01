/**
 * Canonicalizer for XML written in XML
 * Original code in Python xml.dom.ext.c14n class (Python 2.5)
 * 
 * Author: Nimish Pachapurkar (nimishp at gmail dot com)
 * (C) 2007, SpikeSource, Inc.
 *
 * Compatible with Firefox 2+ and IE 7+
 *
 * $Id: c14n.js 81588 2007-06-30 00:52:19Z npac $
 *
 */

/**
 * Usage
 * 
 *       var c = new c14n();
 *       c.comments = true; // Include comments (default: true)
 *       var out = c.canonicalize(xml);
 *
 */

/****************************************
 * Node type dictionary
 *
 * NodeType | Named Constant
 * ====================================
 * 1          ELEMENT_NODE
 * 2          ATTRIBUTE_NODE
 * 3          TEXT_NODE
 * 4          CDATA_SECTION_NODE
 * 5          ENTITY_REFERENCE_NODE
 * 6          ENTITY_NODE
 * 7          PROCESSING_INSTRUCTION_NODE
 * 8          COMMENT_NODE
 * 9          DOCUMENT_NODE
 * 10         DOCUMENT_TYPE_NODE
 * 11         DOCUMENT_FRAGMENT_NODE
 * 12         NOTATION_NODE
 *
*****************************************/

function array_values(arr) {
  var vals = new Array();
  for(var i = 0; i < arr.length; i++) {
    var nv = arr[i];
    vals.push(nv[1]);
  }
  return vals;
}

function updateDict(d1, d2) {
  // for key in d1: d1[key] = d2[key]
  for(k in d1) {
    for(j in d2) {
      if(k == j) {
        d1[k] = d2[j];
      }
    }
  }
  return d1;
}

/**
 * Originally from prototype.js
 */
String.prototype.escapeHTML = function() {
  var div = document.createElement('div');
  var text = document.createTextNode(this);
  div.appendChild(text);
  return div.innerHTML;
}

Array.prototype.values = function() {
  var vals = new Array();
  for(var i = 0; i < this.length; i++) {
    var nv = this[i];
    vals.push(nv[1]);
  }
  return vals;
}

Array.prototype.contains = function(val) {
  for(var i = 0; i < this.length; i++) {
    if(typeof val == 'object') {
      // assume nv pair
      if(this[i][0] == val[0] && this[i][1] == val[1]) {
        return true;
      }
    }
    else {
      if(this[i] == val) return true;
    }
  }
  return false;
}

function c14n() {
  this.root = null;
  this.output = "";
  this._Element = new Array(0, 1, 2);
  this._LesserElement = new Array(0, 1, 2);
  this._GreaterElement = new Array(0, 1, 2);
  this.state = new Array(3);
  this.state[0] = new Array();
  this.state[1] = new Array();
  this.state[1]['xml'] = '';
  this.state[2] = new Array();
  this.BASE = "http://www.w3.org/2000/xmlns/";
  this.XML = "http://www.w3.org/XML/1998/namespace";

  // Comments on?
  this.comments = true;
  this.subset = null;
  this.unsuppressedPrefixes = null;

  // not used
  this.handlers = new Array(12);
  this.handlers[1] = this._do_element;
  this.handlers[9] = this._do_document;
  this.handlers[3] = this._do_text;
  this.handlers[4] = this._do_text;
  this.handlers[7] = this._do_pi;
  this.handlers[8] = this._do_comment;
}

c14n.prototype._in_subset = function(subset, node) {
  if(subset == null) {
    return true;
  }
  for(var i = 0; i < subset.length; i++) {
    if(subset[i] == node) {
      return true;
    }
  }
  return false;
}

c14n.prototype._sorter = function(n1, n2) {
  if(n1.namespaceURI > n2.namespaceURI) {
    return 1;
  }
  else if(n1.namespaceURI < n2.namespaceURI) {
    return -1;
  }
  else {
    if(n1.localName > n2.localName) {
      return 1;
    }
    else if(n1.localName < n2.localName) {
      return -1;
    }
    else {
      return 0;
    }
  }
}

c14n.prototype._sorter_ns = function(n1, n2) {
  if(n1[0] == "xmlns") return -1;
  if(n2[0] == "xmlns") return 1;
  return this._sorter(n1[0], n2[0]);
}

c14n.prototype._utilized = function(n, node, other_attrs, unsuppressedPrefixes) {
  if(n.indexOf("xmlns:") == 0) {
    n = n.substr(6);
  }
  else if(n.indexOf("xmlns") == 0) {
    n = n.substr(5);
  }
  if(n == "" && (node.prefix == "#default" || node.prefix == null) || n == node.prefix) {
    return 1;
  }
  for(var i=0; i < other_attrs.length; i++) {
    var attr = other_attrs[i];
    if(n == attr.prefix) {
      return 1;
    }
  }
  return 0;
}

c14n.prototype._inclusive = function(n) {
  return n.unsuppressedPrefixes == null;
}

c14n.prototype.loadXmlString = function(xml) {
  this.xmlDoc = null;
  // code for IE
  if (window.ActiveXObject) {
    this.xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
    this.xmlDoc.async=false;
    this.xmlDoc.loadXML(xml);
  }
  // code for Mozilla, Firefox, Opera, etc.
  else if (document.implementation && document.implementation.createDocument) {
    var parser = new DOMParser();
    this.xmlDoc = parser.parseFromString(xml, "text/xml");
  }
  else {
    alert('Your browser cannot handle this script');
  }
  return this.xmlDoc;
}

c14n.prototype.canonicalize = function(xml) {
  var doc = this.loadXmlString(xml);
  if(doc == null) {
    return;
  }
  this.root = doc.documentElement;
  var node = doc;

  if(node.nodeType == 9) {
    //document node
    this._do_document(node);
  }
  else if(node.nodeType == 1) {
    // element node
    this.documentOrder = this._Element;
    this._do_element(node);
  }
  else if(node.nodeType == 10) {
    // ignore document_type node
  }
  else {
    alert("Unknown node type: " + node.nodeType);
  }
  return this.output;
}

c14n.prototype._do_document = function(node) {
  // process a document node
  this.documentOrder = this._LesserElement
  for(var i = 0; i < node.childNodes.length; i++) {
    var child = node.childNodes[i];
    if(child.nodeType == 1) {
      // element node
      this.documentOrder = this._Element;
      this._do_element(child);
      this.documentOrder = this._GreaterElement;
    }
    else if(child.nodeType == 7) {
      // processing instruction node
      this._do_pi(child);
    }
    else if(child.nodeType == 8) { //comment node
      this._do_comment(child);
    }
    else if(child.nodeType == 10) { //document type node
      // nothing
    }
    else {
      alert("Error: Unknown node type: " + child.nodeType);
    }
  }
}

c14n.prototype._do_pi = function(node) {
  if(!this._in_subset(this.subset, node)) {
    return;
  }
  if(this.documentOrder == this._GreaterElement) {
    this.output += '\n';
  }
  this.output += "<?";
  this.output += node.nodeName;
  var s = node.data;
  if(s != null) {
    this.output += ' ';
    this.output += s;
  }
  this.output += '?>';
  if(this.documentOrder == this._LesserElement) {
    this.output += '\n';
  }
}

c14n.prototype._do_comment = function(node) {
  if(!this._in_subset(this.subset, node)) {
    return;
  }
  if(this.comments) {
    if(this.documentOrder == this._GreaterElement) {
      this.output += '\n';
    }
    this.output += '<!--';
    this.output += node.data;
    this.output += '-->';
    if(this.documentOrder == this._LesserElement) {
      this.output += '\n';
    }
  }
}

c14n.prototype._do_element = function(node, initial_other_attrs) {
  if(arguments.length == 1) {
    initial_other_attrs = new Array();
  }
  var ns_parent = this.state[0];
  var ns_rendered = this.state[1].slice();
  var xml_attrs = this.state[2].slice();
  var ns_local = ns_parent.slice();
  var xml_attrs_local = [];
  var in_subset = this._in_subset(this.subset, node);
  var other_attrs = initial_other_attrs.slice();

  var attrs = this._attrs(node);
  for(var i = 0; i < attrs.length; i ++) {
    var a = attrs[i];
    if(a.namespaceURI == this.BASE) {
      var n = a.nodeName;
      if(n == "xmlns:") {
        n = "xmlns";
      }
      ns_local[n] = a.nodeValue;
    }
    else if(a.namespaceURI == this.XML) {
      if(this._inclusive(this) || (in_subset && this._in_subset(this.subset, a))) {
        xml_attrs_local[a.nodeName] = a;
      }
    }
    else {
      if(this._in_subset(this.subset, a)) {
        other_attrs.push(a);
      }
    }
    xml_attrs = updateDict(xml_attrs, xml_attrs_local);
  }

  // Render the node
  var name = null;
  if(in_subset) {
    name = node.nodeName;
    this.output += '<';
    this.output += name;

    // Create list of NS attributes to render
    var ns_to_render = new Array();
    for(var i = 0; i < ns_local.length; i++) {
      var n = ns_local[i][0];
      var v = ns_local[i][1];

      if(n == "xmlns" && (v == this.BASE || v == '') && 
        (ns_rendered['xmlns'] == this.BASE || ns_rendered['xmlns'] == '' || ns_rendered['xmlns'] == null)) {
          continue;
      }
      if((n == "xmlns:xml" || n == "xml") && v == "http://www.w3.org/XML/1998/namespace") {
        continue;
      }
      if(!ns_rendered.contains(new Array(n, v)) && (this._inclusive(this) || this._utilized(n, node, other_attrs, this.unsuppressedPrefixes))) {
        ns_to_render.push(new Array(n, v));
      }
    }

    ns_to_render.sort(this._sorter_ns);
    for(var i = 0; i < ns_to_render.length; i++) {
      var nv = ns_to_render[i];
      var n = nv[0];
      var v = nv[1];
      this._do_attr(n, v);
      ns_rendered[n] = v;
    }
    
    if(!this._inclusive(this) || this._in_subset(this.subset, node.parentNode)) {
      other_attrs.concat(xml_attrs_local.values());
    }
    else {
      other_attrs.concat(xml_attrs.values());
    }
    other_attrs.sort(this._sorter);
    for(var i = 0; i < other_attrs.length; i++) {
      var a = other_attrs[i];
      this._do_attr(a.nodeName, a.value);
    }
    this.output += '>';
  }
  state = this.state;
  this.state = new Array(ns_local, ns_rendered, xml_attrs);
  for(var i = 0; i < this._children(node).length; i++) {
    var c = this._children(node)[i];
    switch(c.nodeType) {
    case 1:
      this._do_element(c);
      break;
    case 3:
    case 4:
      this._do_text(c);
      break;
    case 7:
      this._do_pi(c);
      break;
    case 8:
      this._do_comment(c);
      break;
    case 9:
      this._do_document(c);
      break;
    }
    //this.handlers[c.nodeType](this, c);
  }
  if(name != null) {
    this.output += '</' + name +'>';
  }
}

c14n.prototype._do_attr = function(n, value) {
  this.output += ' ';
  this.output += n;
  this.output += '="';
  this.output += value.escapeHTML();
  this.output += '"';
}

c14n.prototype._do_text = function(node) {
  if(!this._in_subset(this.subset, node)) {
    return;
  }
  s = node.nodeValue.escapeHTML();
  this.output += s;
}

c14n.prototype._attrs = function(E) {
  if(E.attributes && array_values(E.attributes)) { 
    return E.attributes;
  }
  return [];
}

c14n.prototype._children = function(E) {
  if(E.childNodes) {
    return E.childNodes;
  }
  return [];
}

c14n.prototype._IN_XML_NS = function(n) {
  return n.name.indexOf("xmlns") == 0;
}


