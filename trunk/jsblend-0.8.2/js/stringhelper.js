/**
 * Author: Nimish Pachapurkar
 * String helper functions (extend String class)
 * $Id: stringhelper.js 81588 2007-06-30 00:52:19Z npac $
*/
String.prototype.trim = function() {
  return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function() {
  return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function() {
  return this.replace(/\s+$/,"");
}

String.prototype.replaceExtraSpaces = function() {
  // Only replace more than one cosecutive white space with nbsp;
  // Except for spaces at the beginning of the string.
  var str = this.replace(/^\s/g, '&nbsp;');
  str = str.replace(/\s\s/g, '&nbsp;&nbsp;');
  var newstr = str;
  do {
    str = newstr;
    newstr = str.replace(/&nbsp;\s/g, '&nbsp;&nbsp;');
  } while (newstr != str);
  return str;
}

String.prototype.htmlchars = function() {
  var str = this.rtrim();
  str = str.escapeHTML();
  str = str.replaceExtraSpaces();
  return str;
}

String.prototype.unhtmlchars = function() {
  var str = this.replace(/&nbsp;/g, " ");
  str = str.unescapeHTML();
  str = str.rtrim();
  return str;
}

String.prototype.formatFilePath = function() {
  var str = this.replace(/\//g, ' /');
  return str.replace(/\\/g, ' \\');
}

String.prototype.getBaseName = function() {
  var i = this.lastIndexOf("/");
  if(i == -1) {
    i = this.lastIndexOf("\\");
  }
  if(i != -1) {
    return this.substr(i+1);
  }
  return this;
}


