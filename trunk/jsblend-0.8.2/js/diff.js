/**
 * Author: Nimish Pachapurkar <npac@spikesource.com>
 * JSBlend tool
 * A cross-browser diff/merge tool written in Javascript.
 * Makes heavy use of Scriptaculous framework.
 * 
 * $Id: diff.js 81588 2007-06-30 00:52:19Z npac $
*/

var left = "";
var right = "";
var editor = null;
var returnto = "";
var actionHistory = new Array();
var markup_s = '<span class="intraline">';
var markup_e = '</span>';
var folds;
var readonly = false;
var autofold = true;
var loaded = false;
var leftsidemode = false;

if(navigator.appName == "Microsoft Internet Explorer") {
  document.onkeydown = doChooseRow;
}
else {
  document.onkeypress = doChooseRow;
}

// Get the actual diff for files.
// Uses the GNU diff command via a server call.
function getDiff() {
    var qstr = location.search.substring(1,location.search.length);
    if(qstr == null) return;
    var qs = qstr.toQueryParams();
    var left = qs["left"];
    var right = qs["right"];
    var retpage = qs["returnto"];
    var isReadonly = qs["readonly"];
    var isLeftSide = qs["editleftonly"];
    if(left == null || left == "" || right == null || right == "") {
      $("left").value = (left == null ? "" : left);
      $("right").value = (right == null ? "" : right);
      $("files").style.display = "block";
      return false;
    }
    if(retpage == null || retpage == "") {
      returnto = "viewdiff.html";
    }
    else {
      returnto = retpage;
    }
    if(isLeftSide != null && (isLeftSide.toLowerCase() == "true" || isLeftSide.toLowerCase() == "yes")) {
      leftsidemode = true;
    }
    if(isReadonly != null && (isReadonly.toLowerCase() == "true" || isReadonly.toLowerCase() == "yes")) {
      readonly = true;
    }
    else {
      $("edit_instr").innerHTML = "";
      if(leftsidemode) {
        $("edit_instr").innerHTML += "<li>To merge the differences, edit and save the left file.</li>";
      }
      //$("edit_instr").innerHTML += "<li>Any merge operation will delete one of the files.</li>";
    }
    getLines(left, right);
    //drawMenu();
}

function removeMarkup(str) {
  str = str.replace(/<span class="intraline">/ig, "");
  str = str.replace(/<span class=intraline>/ig, "");
  str = str.replace(/<\/span>/ig, "");
  return str;
}

function getLineDiff(num) {
  /*
  if(getRowStatus(num, true).value != '' && getRowStatus(num, false).value != '') {
    return;
  }
  */
  $("helper").innerHTML = "<strong>Processing ...</strong>";
  var line1 = removeMarkup(getLeftLine(num).innerHTML);
  var line2 = removeMarkup(getRightLine(num).innerHTML);

  // Use the Javascript implementation of python difflib.SequenceMatcher() class
  // This is part of jsdifflib v1.0. <http://snowtide.com/jsdifflib>
  //var sm = new difflib.SequenceMatcher(line1, line2, function(str) { return (str == " "); } );
  var sm = new difflib.SequenceMatcher(line1, line2, false);
  
  var blocks = sm.get_matching_blocks();
  var newline1 = "";
  var newline2 = "";
  var olds1 = 0;
  var olds2 = 0;
  var oldlen = 0;
  for(var i = 0; i < blocks.length; i++) {
    var s1 = blocks[i][0];
    var s2 = blocks[i][1];
    var len = blocks[i][2];
    if(s1 > olds1 + oldlen) {
      newline1 += markup_s + line1.substr(olds1 + oldlen, s1 - (olds1 + oldlen)) + markup_e;
    }
    newline1 += line1.substr(s1, len);
    if(s2 > olds2 + oldlen) {
      newline2 += markup_s + line2.substr(olds2 + oldlen, s2 - (olds2 + oldlen)) + markup_e;
    }
    newline2 += line2.substr(s2, len);
    olds1 = s1; oldlen = len; olds2 = s2;
  }
  // <Server port="9005" shutdown="0c126f1657b2e4b">
  // 012345678901234567890123456789012345678901234567890
  getLeftLine(num).innerHTML = newline1;
  getRightLine(num).innerHTML = newline2;
  $("helper").innerHTML = "<strong>Done</strong>";
}

function getInPlaceEditorValue() {
  var box = document.getElementById('inplaceeditor_value');
  if(box != null) {
    return box.value;
  }
  return "";
}

function setInPlaceEditorValue(str) {
  var box = document.getElementById('inplaceeditor_value');
  if(box != null) {
    box.value = str;
  }
}

function editedLeftLine(linenum) {
  var box = document.getElementById('inplaceeditor_value');
  if(box != null) {
    return box.descendantOf(getLeftLineCol(linenum));
  }
  return true;
}

function addRowBelowCurrent(isleft) {
  var selectedLine = parseInt($("hidHighlightedLine").value, 10);
  addRow(selectedLine, true, isleft);
}

function deleteRowBelowCurrent(isleft) {
  var selectedLine = parseInt($("hidHighlightedLine").value, 10);
  deleteRow(selectedLine, isleft);
}

function drawMenu() {
  var html = '';
  html += '<table id="menutable" cellspacing="0" cellpadding="0" style="width: 100%;"><tr>';
  if(!readonly) {
    // Undo
    html += '<td style="width: 2%;">';
    if(actionHistory.length > 0) {
      html += '<a href="javascript:void(0);" onclick="undoGlobal();" title="Undo (Ctrl+Z)"><img border="0" src="img/undo.gif" /></a>';
    }
    else {
      html += '<span style="color: rgb(135,135,135);"><img src="img/undo.gif" border="0" /></span>';
    }
    html += '</td>';
    if(!leftsidemode) {
      html += '<td style="width: 2%;"><a href="javascript:void(0);" onclick="doSave(false, \'both\');" title="Save Both Files"><img border="0" src="img/file_save.gif" /></a></td>';
      html += '<td style="width: 2%;"><a href="javascript:void(0);" onclick="doReload();" title="Reload Both Files"><img border="0" src="img/file_reload.gif" /></a></td>';
    }
    else {
      html += '<td style="width: 2%;"><a href="javascript:void(0);" onclick="doSave(false, \'left\');" title="Save"><img border="0" src="img/file_save.gif" /></a></td>';
      html += '<td style="width: 2%;"><a href="javascript:void(0);" onclick="doReload();" title="Reload"><img border="0" src="img/file_reload.gif" /></a></td>';
    }
  }
  html += '<td style="width: 2%;"><a href="javascript:void(0);" onclick="goback();" title="Back to File Selection Page"><img border="0" src="img/back.gif" /></a></td>';
  if(!readonly) {
    // Add line
    html += '<td style="width: 5%;"><a href="javascript:void(0);" onclick="addRowBelowCurrent(true);" title="Add line in left file below selected line"><img src="img/insertrow_left.gif" border="0" /></a>&nbsp;';
    if(!leftsidemode) {
      // Add line
      html += '<a href="javascript:void(0);" onclick="addRowBelowCurrent(false);" title="Add line in right file below selected line"><img src="img/insertrow_right.gif" border="0" /></a></td>';
    }
    // Delete line
    html += '<td style="width: 5%;"><a href="javascript:void(0);" onclick="deleteRowBelowCurrent(true);" title="Delete selected line in left file"><img src="img/deleterow_left.gif" border="0" /></a>&nbsp;';
    if(!leftsidemode) {
      // Delete line
      html += '<a href="javascript:void(0);" onclick="deleteRowBelowCurrent(false);" title="Delete selected line in right file"><img src="img/deleterow_right.gif" border="0" /></a></td>';
    }
  }
  html += '<td style="width: 4%;"><a href="javascript:void(0);" onclick="nextDiff(getSelectedLineNum());" title="Go to next diff (n)"><img src="img/diff_next.gif" border="0" /></a>&nbsp;';
  html += '<a href="javascript:void(0);" onclick="previousDiff(getSelectedLineNum());" title="Go to previous diff (p)"><img src="img/diff_previous.gif" border="0" /></a></td>';
  html += '<td style="font-family: verdana, serif; font-size: 1.4em; text-align: right; padding-right: 10px;"><a href="http://developer.spikesource.com/wiki/index.php/Projects:JSBlend" title="JSBlend Home">JSBlend</a></td>';
  html += '</tr></table>';
  $("menu").innerHTML = html;
  $("menu").style.display = "block";
}

// getPageSize()
// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
//
function getPageSize(){

  var xScroll, yScroll;

  if (window.innerHeight && window.scrollMaxY) {
    xScroll = document.body.scrollWidth;
    yScroll = window.innerHeight + window.scrollMaxY;
  } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
    xScroll = document.body.scrollWidth;
    yScroll = document.body.scrollHeight;
  } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
    xScroll = document.body.offsetWidth;
    yScroll = document.body.offsetHeight;
  }

  var windowWidth, windowHeight;
  if (self.innerHeight) { // all except Explorer
    windowWidth = self.innerWidth;
    windowHeight = self.innerHeight;
  } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
    windowWidth = document.documentElement.clientWidth;
    windowHeight = document.documentElement.clientHeight;
  } else if (document.body) { // other Explorers
    windowWidth = document.body.clientWidth;
    windowHeight = document.body.clientHeight;
  }

  // for small pages with total height less then height of the viewport
  if(yScroll < windowHeight){
    pageHeight = windowHeight;
  } else { 
    pageHeight = yScroll;
  }

  // for small pages with total width less then width of the viewport
  if(xScroll < windowWidth){
    pageWidth = windowWidth;
  } else {
    pageWidth = xScroll;
  }

  arrayPageSize = new Array();
  arrayPageSize['pageWidth'] = pageWidth;
  arrayPageSize['pageHeight'] = pageHeight;
  arrayPageSize['windowWidth'] = windowWidth;
  arrayPageSize['windowHeight'] = windowHeight;

  //pageWidth,pageHeight,windowWidth,windowHeight
  return arrayPageSize;
}

function getLineNumCol(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("td")[0];
  }
  return null;
}

function getLeftLineCol(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("td")[1];
  }
  return null;
}

function getRightLineCol(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("td")[3];
  }
  return null;
}

function getLeftLine(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("code")[0];
  }
  return null;
}

function getRightLine(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("code")[1];
  }
  return null;
}

function getLeftLineOrig(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("textarea")[0];
  }
  return null;
}

function getRightLineOrig(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("textarea")[1];
  }
  return null;
}

function getRow(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    return $("diff_table_body").getElementsByTagName("tr")[rownum];
  }
  return null;
}

function getParentRowNum(obj) {
  var rows = $("diff_table_body").getElementsByTagName("tr");
  for(var i = 0; i < rows.length; i ++) {
    if(Element.extend(obj).descendantOf(rows[i])) {
      return i;
    }
  }
  return -1;
}

function getActionColumn(rownum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    return row.getElementsByTagName("td")[2];
  }
  return null;
}

function getRowStatus(rownum, isleft) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(rownum >= 0 && rownum < lines) {
    var row = $("diff_table_body").getElementsByTagName("tr")[rownum];
    if(isleft) {
      return row.getElementsByTagName("input")[0];
    }
    else {
      return row.getElementsByTagName("input")[1];
    }
  }
  return null;
}

function pushToActionHistory(action) {
  actionHistory.push(action);
  drawMenu();
}

function deleteRow(num, isleft) {
  if(readonly) {
    $("helper").innerHTML = '<strong class="escape">ReadOnly mode! Cannot edit!!</strong>';
    return;
  }
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  var stat = getRowStatus(num, isleft).value;
  var otherstat = getRowStatus(num, !isleft).value;
  if(stat == "a" && otherstat == "a") {
    $("diff_table_body").deleteRow(num);
    num --;
    fixAllRows(num);
    if(num == lines) num --;
    highlightLine(num);
  }
  else {
    getRowStatus(num, isleft).value = "d";
    //Element.extend(getRow(num)).addClassName("removed");
    if(isleft) {
      getLeftLine(num).innerHTML = "";
    }
    else {
      getRightLine(num).innerHTML = "";
    }
  }
  if(isleft) {
    pushToActionHistory("ld" + num);
  }
  else {
    pushToActionHistory("rd" + num);
  }
  repaintLine(num);
  if(autofold) foldRows();
}

function addRow(after, edit, isleft) {
  if(readonly) {
    $("helper").innerHTML = '<strong class="escape">ReadOnly mode! Cannot edit!!</strong>';
    return;
  }
  unfold(after);
  var rownum = after+1;
  var newRow = Element.extend($("diff_table_body").insertRow(rownum));
  newRow.addClassName('deleted');
  var cell = Element.extend(newRow.insertCell(0));
  cell.addClassName("line");
  cell.innerHTML = (rownum+1);
  cell = Element.extend(newRow.insertCell(1));
  cell.addClassName("leftfile");
  var stat = '';
  if(isleft) {
    stat = "la";
  }
  else {
    stat = "ra";
  }
  cell.innerHTML = '<code onclick="highlightLine(getParentRowNum(this));" ondblclick="editLine(getParentRowNum(this), true);" title="Double-click to Edit (enter)"></code><textarea readOnly="true" style="display: none;" rows="1"></textarea><input type="hidden" size="3" value="a"/>';
  cell = Element.extend(newRow.insertCell(2));
  cell.innerHTML = '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), true);" title="Copy line to left (shift+left)"><img src="img/arrow_left.gif" alt="left arrow icon" /></a>';
  if(!leftsidemode) {
    cell.innerHTML += '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), false);" title="Copy line to right (shift+right)"><img src="img/arrow_right.gif" alt="right arrow icon" /></a>';
  }
  cell.addClassName("diff");
  cell = Element.extend(newRow.insertCell(3));
  cell.addClassName("rightfile");
  var htmlstr = '<code onclick="highlightLine(getParentRowNum(this));" ';
  if(!leftsidemode) {
    htmlstr += 'ondblclick="editLine(getParentRowNum(this), false);" title="Double-click to Edit (shift+enter)"';
  }
  htmlstr += '></code><textarea readOnly="true" style="display: none;" rows="1"></textarea><input type="hidden" size="3" value="a"/>';
  cell.innerHTML = htmlstr;
  fixAllRows(rownum);
  if(isleft) {
    pushToActionHistory("la" + rownum);
  }
  else {
    pushToActionHistory("ra" + rownum);
  }
  if(autofold) foldRows();
  if(edit) {
    highlightLine(rownum);
    editLine(rownum, isleft);
  }
}

function fixAllRows(newRow) {
  var rows = $("diff_table_body").getElementsByTagName("tr");
  for(var i = newRow + 1; i < rows.length; i++) {
    var col = rows[i].getElementsByTagName("td")[0];
    //col.innerHTML = '<a href="javascript:void(0);" onclick="addRow(getParentRowNum(this));"><img src="img/plus.jpg" alt="Add row"/></a> <a href="javascript:void(0);" onclick="deleteRow(getParentRowNum(this));"><img src="img/minus.jpg" alt="Delete row"/></a>&nbsp;' + (i+1);
    col.innerHTML = (i+1);
  }
}

function foldRows() {
  $("helper").innerHTML = "<strong>Processing ...</strong>";
  folds = new Array();
  var fold = new Array();
  var context = 2;
  var minFoldSize = 3;
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  for(var i = 0; i < lines; i++) {
    getLineNumCol(i).innerHTML = (i+1);
    var ele = Element.extend(getRow(i));
    if(ele.hasClassName("folded")) ele.removeClassName("folded");
  }
  for(var i = 0; i <= lines; i++) {
    // context is 5 lines +/-
    if(i != lines && getActionColumn(i).innerHTML.indexOf("copyLine") == -1) {
      fold.push(i);    
    }
    else {
      if(i != lines) {
        // cannot be folded
        // unfold context 
        for(var j = 0; j < context; j++) {
          if(fold.length > 0) {
            fold.pop();
          }
          else {
            break;
          }
        }
      }
      // create fold
      if(fold.length > minFoldSize) {
        getLineNumCol(fold[0]).innerHTML = '<a href="javascript:void(0);" onclick="unfold(getParentRowNum(this));" title="Unfold"><img src="img/plus.jpg" alt="+"/></a>&nbsp;' + (fold[0]+1) + '<br/>(' + (fold.length-1) + '&nbsp;more)';
        for(var j = 1; j < fold.length; j++) {
          var ele = Element.extend(getRow(fold[j]));
          if(!ele.hasClassName("folded")) ele.addClassName("folded");
          getLineNumCol(fold[j]).innerHTML = (fold[j]+1);
        }
        // save fold start, fold end, and state (folded)
        folds.push([fold[0], fold[fold.length-1], 1]);
        i += (context - 1);
      }
      fold = new Array();
    }
  }
  $("helper").innerHTML = "<strong>Done</strong>";
  var highlightedLine = parseInt($("hidHighlightedLine").value, 10);
  //unfold(highlightedLine);
  if(highlightedLine != -1 && isFolded(highlightedLine)) {
    highlightLine(folds[getFold(highlightedLine)][0]);
  }
}

function unfoldRows() {
  for(var i = 0; i < folds.length; i++) {
    getLineNumCol(folds[i][0]).innerHTML = '<a href="javascript:void(0);" onclick="fold(getParentRowNum(this));" title="Fold"><img src="img/minus.jpg" alt="Fold"/></a>&nbsp;' + (folds[i][0]+1);
    for(var j = folds[i][0]+1; j < folds[i][1]; j++) {
      var ele = Element.extend(getRow(j));
      if(ele.hasClassName("folded")) ele.removeClassName("folded");
    }
    // Mark unfolded
    folds[i][2] = 0;
  }
}

function isFolded(rownum) {
  for(var i = 0; i < folds.length; i++) {
    var tuple = folds[i];
    if(rownum >= tuple[0] && rownum <= tuple[1]) {
      return tuple[2] == 1;
    }
  }
  return false;
}

function getFold(rownum) {
  for(var i = 0; i < folds.length; i++) {
    var tuple = folds[i];
    if(rownum >= tuple[0] && rownum <= tuple[1]) {
      return i;
    }
  }
  return -1;
}

function fold(rownum) {
  for(var i = 0; i < folds.length; i++) {
    var tuple = folds[i];
    if(rownum >= tuple[0] && rownum <= tuple[1]) {
      // fold
      getLineNumCol(tuple[0]).innerHTML = '<a href="javascript:void(0);" onclick="unfold(getParentRowNum(this));" title="Unfold"><img src="img/plus.jpg" alt="Unfold"/></a>&nbsp;' + (tuple[0]+1) + '<br/>(' + (tuple[1]-tuple[0]) + '&nbsp;more)';
      for(var j = tuple[0]+1; j <= tuple[1]; j++) {
        var ele = Element.extend(getRow(j));
        if(!ele.hasClassName("folded")) ele.addClassName("folded");
      }
      folds[i][2] = 1;
      highlightLine(tuple[0]);
      break;
    }
  }
}

function unfold(rownum) {
  for(var i = 0; i < folds.length; i++) {
    var tuple = folds[i];
    if(rownum >= tuple[0] && rownum <= tuple[1]) {
      // unfold
      getLineNumCol(tuple[0]).innerHTML = '<a href="javascript:void(0);" onclick="fold(getParentRowNum(this));" title="Fold"><img src="img/minus.jpg" alt="+"/></a>&nbsp;' + (tuple[0]+1);
      for(var j = tuple[0]+1; j <= tuple[1]; j++) {
        var ele = Element.extend(getRow(j));
        if(ele.hasClassName("folded")) ele.removeClassName("folded");
      }
      folds[i][2] = 0;
      break;
    }
  }
}

function getRemoteHost(str) {
  var parts = str.split(':')
  if(parts.length > 2) {
    return parts[0] + ':' + parts[1];
  }
  else {
    return str;
  }
}

function paintDiffTable(transport) {
  if(transport.readyState == 4 || transport.readyState == "complete") {
      var resp = transport.responseText;
      if(resp.indexOf("ERROR:") == 0) {
        // error
        $("diff_table_c").innerHTML = "";
        $("error_c").innerHTML = '<pre class="error">' + resp.htmlchars() + '<pre>';
        $("files").style.display = "block";
        return;
      }
      else if(resp.indexOf('PASSWORDLEFT:') == 0 || resp.indexOf("PASSWORDRIGHT:") == 0) {
        // this is a password request
        $("txtPasswdLeftId").style.display = "none";
        $("txtPasswdRightId").style.display = "none";
        $("passwd_c").style.display = "block";
        $("left").value = left;
        $("right").value = right;
        // TODO: add readonly handling
        if(resp.indexOf("PASSWORDLEFT:") == 0) {
            $("remotehost").innerHTML = getRemoteHost(left);
            $("txtPasswdLeftId").style.display = "block";
            $("txtPasswdLeftId").focus();
            $("hidPasswordType").value = "left";
        }
        else {
            $("remotehost").innerHTML = getRemoteHost(right);
            $("txtPasswdRightId").style.display = "block";
            $("txtPasswdRightId").focus();
            $("hidPasswordType").value = "right";
        }
        return; 
      }
      var lines = resp.split("\n");
      // Get number of columns per line.
      if(lines[0].indexOf("COLUMNS:") == 0) {
        var line = lines.shift();
        cols = line.substring(8);
        //alert("Cols" + cols);
      }
      var buttonpatti = '';
      buttonpatti += '<tr style="background-color: rgb(230,230,230);"><td class="line">';
      buttonpatti += '<a href="javascript:void(0);" onclick="foldRows();" title="Fold"><img src="img/minus.jpg" alt="Fold"/></a>&nbsp;';
      buttonpatti += '<a href="javascript:void(0);" onclick="unfoldRows();" title="Unfold"><img src="img/plus.jpg" alt="Unfold"/></a></td>';
      buttonpatti += '<td class="leftfile" style="text-align:left; vertical-align:middle;">';
      if(!readonly) {
        buttonpatti += '<input type="button" class="bluebutton" value="Save Changes &amp; Delete the Other" onclick="doSave(true, \'left\');"/>';
        buttonpatti += '&nbsp;<input type="button" class="bluebutton" value="Ignore Changes &amp; Delete the Other" onclick="doAllLeft();"/>';
      }
      //buttonpatti += '&nbsp;<input type="button" class="bluebutton" value="Ignore Changes &amp; Back" onclick="goback();"/>';
      //buttonpatti += '&nbsp;<label><input type="checkbox" value="merge" name="merge" id="chkMergeLeft" /> Merge? (deletes the other file)</label>';
      buttonpatti += '&nbsp;</td>';
      buttonpatti += '<td class="diff">&nbsp;</td><td class="rightfile">';
      if(!readonly) {
        if(!leftsidemode) {
          buttonpatti += '<input type="button" class="bluebutton" value="Save Changes &amp; Delete the Other" onclick="doSave(true, \'right\');"/>';
          buttonpatti += '&nbsp;<input type="button" class="bluebutton" value="Ignore Changes &amp; Delete the Other" onclick="doAllRight();"/>&nbsp;';
        }
        else {
          buttonpatti += '<input type="button" class="bluebutton" value="Keep Original" onclick="doAllRight();"/>';
        }
        //buttonpatti += '&nbsp;<label><input type="checkbox" value="merge" name="merge" id="chkMergeRight" /> Merge? (deletes the other file)</label>';
      }
      buttonpatti += '&nbsp;</td>';
      buttonpatti += '</tr>';
      var html = '';
      html += '<table id="diff_table" cellspacing="0" cellpadding="0">';
      html += '<!-- heading -->';
      html += '<thead id="heading">';
      html += '<tr>';
      html += '<th class="line">#</th>';
      html += '<th class="leftfile">Left File';
      if(!readonly) html += ' (editable)';
      html += ': ' + left + '</th>'
      html += '<th class="diff">&nbsp;</th>';
      html += '<th class="rightfile">Right File';
      if(!readonly && !leftsidemode) {
        html += ' (editable)';
      }
      else {
        html += ' (readonly)';
      }
      html += ': ' + right + '</th>';
      html += '</tr>';
      html += buttonpatti;
      html += '</thead>';
      html += '<tbody id="diff_table_body">';
      for(var i = 0; i < lines.length; i++) {
        var symbol = lines[i].substr(parseInt(cols/2, 10), 1);
        var text1 = lines[i].substr(0, parseInt(cols/2, 10) - 1).htmlchars();
        var text2 = lines[i].substr(parseInt(cols/2+2, 10)).htmlchars();
        var left_style = "";
        var right_style = "";

        var row_class = "";
        var row_status = "";
        var rrow_status = "";
        
        switch(symbol) {
          case "<":
            row_class = 'deleted';
            row_status = "oa";
            rrow_status = "od";
            break;
          case ">":
            row_class = 'added';
            row_status = "od";
            rrow_status = "oa";
            break;
          case "|":
          case "\\":
          case "/":
            row_class = 'changed';
            break;
          default:
            symbol = " ";
            break;
        }
        html += '<tr class="' + row_class + '">';
        html += '<td class="line">' + (i+1) + '</td>';
        html += '<td class="leftfile">';
        html += '<code onclick="highlightLine(getParentRowNum(this));" ondblclick="editLine(getParentRowNum(this), true);" title="Double-click to Edit (enter)">' + (text1=='' ? text1 : text1) + '</code>';
        html += '<textarea readOnly="true" style="display: none;" rows="1">' + (text1=='' ? text1 : text1) + '</textarea>';
        html += '<input type="hidden" size="3" value="' + row_status + '"/>';
        html += '</td>';
        html += '<td class="diff">';
        if(symbol != " ") {
          html += '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), true);" title="Copy line to left (shift+left)"><img src="img/arrow_left.gif" alt="left arrow icon" /></a> ';
          if(!leftsidemode) {
            html += '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), false);" title="Copy line to right (shift+right)"><img src="img/arrow_right.gif" alt="right arrow icon" /></a>';
          }
        }
        else {
          html += '&nbsp;';
        }
        html += '</td>';
        html += '<td class="rightfile">';
        html += '<code onclick="highlightLine(getParentRowNum(this));" ';
        if(!leftsidemode) {
          html += 'ondblclick="editLine(getParentRowNum(this), false);" title="Double-click to Edit (shift+enter)"';
        }
        html += '>' + (text2=='' ? text2 : text2) + '</code>';
        html += '<textarea readOnly="true" style="display: none;" rows="1">' + (text2=='' ? text2 : text2) + '</textarea>';
        html += '<input type="hidden" size="3" value="' + rrow_status + '"/>';
        html += '</td>';
        html += '</tr>';
      }
      html += '</tbody>';
      html += buttonpatti;
      html += '<tr><td colspan="4">&nbsp;</td></tr>';
      html += '</table>';
      html += '<br/><br/><br/>';
      html += '<input type="hidden" id="leftFile" value="' + left + '"/>';
      html += '<input type="hidden" id="rightFile" value="' + right + '"/>';
      document.getElementById("diff_table_c").innerHTML = html;
      document.getElementById("hidHighlightedLine").value = -1;
      for(i = 0; i < lines.length; i++) {
        if(getActionColumn(i).innerHTML != '&nbsp;') {
          repaintLine(i);
        }
      }
      foldRows();
      highlightLine(0);
      drawMenu();
  }
}

function getLines(l, r) {
  left = l;
  right = r;
  var cols = 301;
  var url = "getfiles.php";
  var param = "?method=getFiles&left=" + escape(left) + "&right=" + escape(right);
  var xhr_get_file = new Ajax.Request(url + param, {
    method: 'get',
    onLoading: function(transport) {
      // not ready yet!
      if(transport.readyState != 4 && transport.readyState != "complete") {
        document.getElementById("diff_table_c").innerHTML = '<br/><br/><center><img src="img/spin.gif" alt="loading"/> Loading ...</center>';
      }
    },
    onSuccess: paintDiffTable
  });
}

function highlightLine(num) {
  if(readonly) return;
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(num >= lines || num < 0) {
    return;
  }
  var oldnum = parseInt(document.getElementById('hidHighlightedLine').value, 10);
  if(isFolded(num)) {
    var foldi = getFold(num);
    if(oldnum < num) {
      // going down
      if(num > folds[foldi][0]) {
        num = folds[foldi][1]+1;
      }
    }
    else {
      // Going up
      if(num == folds[foldi][1]) {
        num = folds[foldi][0];
      }
    }
  }
  if(num >= lines || num < 0) {
    return;
  }
  if(oldnum != -1) {
    Element.extend(getRow(oldnum)).removeClassName('hilite');
  }
  $('hidHighlightedLine').value = num;
  var newrow = Element.extend(getRow(num));
  newrow.addClassName('hilite');
  var size = getPageSize();
  // offset of selected line
  var offset = Position.cumulativeOffset(getLeftLine(num));
  var topFromPageTop = Position.page(getLeftLine(num))[1];
  if((size['windowHeight'] <= offset[1] || offset[1] <= window.pageYOffset) && (topFromPageTop >= (size['windowHeight'] - 20) || topFromPageTop < 0)) {
    var scrollNum = (num == 0) ? num : num - 1;
    new Element.scrollTo(getRow(scrollNum));
  }
  $("helper").innerHTML = "";
  var lstatus = getRowStatus(num, true).value; 
  var rstatus = getRowStatus(num, false).value;
  if(lstatus == "a" || lstatus == "oa") {
    $("helper").innerHTML = '<strong>[New Line] </strong> ';
  }
  else if(lstatus == "ld" || lstatus == "rd" || lstatus == "od") {
    $("helper").innerHTML = '<strong>[Deleted Line] </strong>';
  }
  $("helper").innerHTML += "<strong class=\"enter\">&lt;enter&gt;</strong> Edit left";
  if(!leftsidemode) {
    $("helper").innerHTML += "<strong>&lt;shift + enter&gt;</strong> Edit right";
  }
  $("helper").innerHTML += "<strong>&lt;+&gt;</strong> Add a left line below";
  if(!leftsidemode) {
    $("helper").innerHTML += "<strong>&lt;shift + +&gt;</strong> Add a right line below";
  }
  $("helper").innerHTML += "<strong>&lt;delete&gt;</strong> Delete left line";
  if(!leftsidemode) {
    $("helper").innerHTML += "<strong>&lt;shift + delete&gt;</strong> Delete right line";
  }
  //$("helper").innerHTML += "<strong>&lt;p&gt;</strong> Previous diff";
  //$("helper").innerHTML += "<strong>&lt;n&gt;</strong> Next diff";
  //$("helper").innerHTML += "<strong>&lt;up/down arrow&gt;</strong> Navigate";
  if(getActionColumn(num).innerHTML != '&nbsp;') {
    $("helper").innerHTML += "<strong>&lt;shift + left&gt;</strong> Apply text from right";
    if(!leftsidemode) {
      $("helper").innerHTML += "<strong>&lt;shift + right&gt;</strong> Apply text from left";
    }
  }
  if(removeMarkup(getLeftLine(num).innerHTML) != getLeftLineOrig(num).value.htmlchars()) {
    $("helper").innerHTML += "<strong>&lt;u&gt;</strong> Undo editing for left line";
    if(!leftsidemode && removeMarkup(getRightLine(num).innerHTML) != getRightLineOrig(num).value.htmlchars()) {
      $("helper").innerHTML += "<strong>&lt;shift + u&gt;</strong> Undo editing for right line";
    }
  }
}

function preventPropagation(evt) {
  if(window.event) {
    // IE
    window.event.keyCode = 0;
    window.event.cancelBubble = true;
  }
  else {
    evt.preventDefault();
  }
}

function getSelectedLineNum() {
  return parseInt(document.getElementById('hidHighlightedLine').value, 10);
}

function doChooseRow(evt) {
  if(document.getElementById("diff_table_body") == null || readonly) {
    return;
  }
  var keyCode = (window.event) ? window.event.keyCode : evt.keyCode;
  var charCode = (window.event) ? window.event.keyCode : evt.charCode;
  var ctrlKey = (window.event) ? window.event.ctrlKey : evt.ctrlKey;
  var altKey = (window.event) ? window.event.altKey : evt.altKey;
  var shiftKey = (window.event) ? window.event.shiftKey : evt.shiftKey;

  var selectedLine = getSelectedLineNum();
  var text = getLeftLine(selectedLine);
  if(keyCode == 40 && !altKey && !ctrlKey) {
    // down
    if(editor == null && selectedLine < $("diff_table_body").getElementsByTagName("tr").length -1) {
      highlightLine(selectedLine + 1);
      preventPropagation(evt);
      return false;
    }
  }
  else if(keyCode == 38 && !altKey && !ctrlKey) {
    // up
    if(editor == null && selectedLine > 0) {
      highlightLine(selectedLine - 1);
      preventPropagation(evt);
      return false;
    }
  }
  else if(keyCode == 37 && !altKey && !ctrlKey) {
    // Left
    if(editor == null) {
      if(shiftKey) {
        copyLine(selectedLine, true);
      }
      else {
        fold(selectedLine);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(keyCode == 39 && !altKey && !ctrlKey) {
    // Right
    if(editor == null) {
      if(shiftKey) {
        copyLine(selectedLine, false);
      }
      else {
        unfold(selectedLine);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(keyCode == 13  && !altKey && !ctrlKey) {
    // enter
    if(editor == null) {
      if(shiftKey) {
        // edit right half
        editLine(selectedLine, false);
      }
      else {
        editLine(selectedLine, true);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(keyCode == 27 && !altKey && !ctrlKey) {
    // Escape
    uneditLine(selectedLine);
    preventPropagation(evt);
    return false;
  }
  else if(keyCode == 46 && !altKey && !ctrlKey) {
    // Delete
    if(editor == null) {
      if(shiftKey) {
        deleteRow(selectedLine, false);
      }
      else {
        deleteRow(selectedLine, true);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(!altKey && !ctrlKey && (charCode == 43 || charCode == 61)) {
    // + or =
    if(editor == null) {
      if(!shiftKey) {
        addRow(selectedLine, true, true);
      }
      else {
        addRow(selectedLine, true, false);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(!ctrlKey && !altKey && (charCode == 117 || charCode == 85)) {
    // u or U
    if(editor == null) {
      // Only undo if it is in non-edit mode.
      if(shiftKey) {
        undoEdit(selectedLine, false);
      }
      else {
        undoEdit(selectedLine, true);
      }
      preventPropagation(evt);
      return false;
    }
  }
  else if(ctrlKey && !altKey && (charCode == 122 || charCode == 90)) {
    // CTRL+Z
    if(editor == null) {
      undoGlobal();
      preventPropagation(evt);
      return false;
    }
  }
  else if(!ctrlKey && !altKey && (charCode == 110 || charCode == 78)) {
    // n or N
    if(editor == null) {
      // Go to next diff
      nextDiff(selectedLine);
      preventPropagation(evt);
      return false;
    }
  }
  else if(!ctrlKey && !altKey && (charCode == 112 || charCode == 80)) {
    // p or P
    if(editor == null) {
      // Go to previous diff
      previousDiff(selectedLine);
      preventPropagation(evt);
      return false;
    }
  }
  else {
    // Editing textarea - auto-resize
  }
}

function nextDiff(linenum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  $("helper").innerHTML = linenum + " " + lines;
  if(linenum < lines && linenum >= 0) {
    for(var i = linenum+1; i < (lines + linenum); i++) {
      //if(i == lines) i++;
      var move = getActionColumn(i % lines);
      if(move.innerHTML != '&nbsp;') {
        highlightLine(i % lines);
        break;
      }
    }
    if(i == lines + linenum) {
      highlightLine(linenum);
    }
  }
}

function previousDiff(linenum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(linenum < lines && linenum >= 0) {
    for(var i = linenum - 1; i >= (linenum - lines); i--) {
      //if(i == 0) i--;
      var move = getActionColumn((lines + i) % lines);
      if(move.innerHTML != '&nbsp;') {
        highlightLine((lines + i) % lines);
        break;
      }
    }
    if(i < (linenum - lines)) {
      highlightLine(linenum);
    }
  }
}

function copyLine(linenum, rightToLeft) {
  if(readonly) {
    $("helper").innerHTML = '<strong class="escape">ReadOnly mode! Cannot edit!!</strong>';
    return;
  }
  if(leftsidemode && !rightToLeft) {
    $("helper").innerHTML = '<strong class="escape">Right file is read only. Cannot edit!</strong>';
    return;
  }
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(linenum < lines && linenum >= 0) {
    var lstatus = getRowStatus(linenum, true).value;
    var rstatus = getRowStatus(linenum, false).value;
    if(lstatus == "a") {
      undoEdit(linenum, true);
    }
    else if(rstatus == "a") {
      undoEdit(linenum, false);
    }
    else {
      if(lstatus == "d") {
        getRowStatus(linenum, true).value = "";
      }
      if(rightToLeft) {
        getLeftLine(linenum).innerHTML = removeMarkup(getRightLine(linenum).innerHTML);
        pushToActionHistory("lc" + linenum);
      }
      else {
        getRightLine(linenum).innerHTML = removeMarkup(getLeftLine(linenum).innerHTML);
        pushToActionHistory("rc" + linenum);
      }
      getLineDiff(linenum);
      repaintLine(linenum);
    }
    if(autofold) foldRows();
  }
}

function undoGlobal() {
  if(actionHistory.length > 0) {
    var action = actionHistory.pop();
    $("thisaction").value = action;
    var command = action.substr(0,2);
    var line = parseInt(action.substr(2), 10);
    var lstat = getRowStatus(line, true).value;
    var rstat = getRowStatus(line, false).value;
    if(command == "lc" || command == "ld") {
      undoEdit(line, true);
    }
    else if(command == "rc" || command == "rd") {
      undoEdit(line, false);
    }
    else if(command == "la" && rstat != "a") {
      deleteRow(line, true);
    }
    else if(lstat != "a" && command == "ra") {
      deleteRow(line, false);
    }
    else if(lstat == "a" && rstat == "a" && (command == "la" || command == "ra")) {
      if(command == "la") {
        undoEdit(line, true);
      }
      else if(command == "ra"){
        undoEdit(line, false);
      }
    }
    //if(actionHistory.length > 0) actionHistory.pop();
  }
  $("actions").value = actionHistory.join("\n");
  drawMenu();
}

function undoEdit(linenum, isleft) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(linenum < lines && linenum >= 0) {
    var stat = getRowStatus(linenum, isleft).value;
    var otherstat = getRowStatus(linenum, !isleft).value;
    if(stat == "a" && otherstat == "a") {
      deleteRow(linenum, isleft);
    }
    else {
      if(stat == "d") {
        getRowStatus(linenum, isleft).value = "";
      }
      if(isleft) {
        getLeftLine(linenum).innerHTML = getLeftLineOrig(linenum).value.htmlchars();
      }
      else {
        getRightLine(linenum).innerHTML = getRightLineOrig(linenum).value.htmlchars();
      }
      getLineDiff(linenum);
      repaintLine(linenum);
    }
    if(autofold) foldRows();
  }
}

function uneditLine(linenum) {
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  var isleft = editedLeftLine(linenum);
  var origlinenum = linenum;
  if(linenum < lines && linenum >= 0) {
    var textleft = getLeftLine(linenum);
    var textright = getRightLine(linenum);
    if(editor != null) {
      var text = getInPlaceEditorValue();
      var textlines = text.split("\n");
      for(var i = 0; i < textlines.length; i++) {
        if(i > 0) {
          addRow(linenum, false, isleft);
          linenum++;
          if(isleft) {
            getLeftLineOrig(linenum).value = textlines[i].htmlchars();
          }
          else {
            getRightLineOrig(linenum).value = textlines[i].htmlchars();
          }
        }
        else {
          if(isleft && (getRowStatus(linenum, isleft).value != "a" || (getLeftLineOrig(linenum).value != textlines[i].htmlchars()))) {
            pushToActionHistory("lc" + linenum);
          }
          if(!isleft && (getRowStatus(linenum, isleft).value != "a" || (getRightLineOrig(linenum).value != textlines[i].htmlchars()))) {
            pushToActionHistory("rc" + linenum);
          }
        }
        if(isleft) {
          getLeftLine(linenum).innerHTML = textlines[i].htmlchars();
        }
        else {
          getRightLine(linenum).innerHTML = textlines[i].htmlchars();
        }
        getLineDiff(linenum);
      }
      editor.dispose();
      editor = null;
    }
    repaintLine(origlinenum);
    if(autofold) foldRows();
  }
}

function editLine(linenum, isleft) {
  if(readonly) {
    $("helper").innerHTML = '<strong class="escape">ReadOnly mode! Cannot edit!!</strong>';
    return;
  }
  if(!isleft && leftsidemode) {
    $("helper").innerHTML = '<strong class="escape">Right side file is opened in Read only mode. Cannot edit!!</strong>';
    return;
  }
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  if(linenum < lines && linenum >= 0) {
    if(editor != null) {
      uneditLine(linenum, !isleft);
    }
    unfold(linenum);
    highlightLine(linenum);
    if(isleft) {
      var textorig = getLeftLine(linenum);
      editor = new Ajax.InPlaceEditor(getLeftLine(linenum), "return false;", {okButton: false, cancelLink: false, rows: 3});
    }
    else {
      var textorig = getRightLine(linenum);
      editor = new Ajax.InPlaceEditor(getRightLine(linenum), "return false;", {okButton: false, cancelLink: false, rows: 3});
    }
    editor.enterEditMode('click');
    setInPlaceEditorValue(removeMarkup(textorig.innerHTML).unhtmlchars());
    $("helper").innerHTML = "<strong class=\"escape\">&lt;escape&gt;</strong> Exit edit";
  }
}

function repaintLine(linenum) {
  var leftLine = getLeftLine(linenum);
  var rightLine = getRightLine(linenum);

  var tr = Element.extend(getRow(linenum));
  var left_ori = getLeftLineOrig(linenum);
  var right_ori = getRightLineOrig(linenum);
  
  tr.removeClassName('added');
  tr.removeClassName('edited');
  tr.removeClassName('changed');
  tr.removeClassName('deleted');

  var lstatus = getRowStatus(linenum, true).value;
  var rstatus = getRowStatus(linenum, false).value;
  getActionColumn(linenum).innerHTML = "";
  if(removeMarkup(leftLine.innerHTML) != left_ori.value.htmlchars()) {
    // edited
    getActionColumn(linenum).innerHTML = '<a href="javascript:void(0);" onclick="undoEdit(getParentRowNum(this), true);" title="Revert changes on left side (u)"><img src="img/undo-left.gif" alt="revert arrow icon" /></a>';
    //tr.addClassName('edited');
  }
  if(removeMarkup(leftLine.innerHTML) != removeMarkup(rightLine.innerHTML) || lstatus != "") {
    if(lstatus == "a" && rstatus == "a") {
      tr.addClassName('changed');
      getLineDiff(linenum);
    }
    else if(lstatus == "d" || lstatus == "od" || rstatus == "d" || rstatus == "oa") {
      tr.addClassName('deleted');
    }
    else if(lstatus == "a" || lstatus == "oa" || rstatus == "a" || rstatus == "od") {
      tr.addClassName('added');
    }
    else {
      tr.addClassName('changed');
      getLineDiff(linenum);
    }
    getActionColumn(linenum).innerHTML += '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), true);" style="text-decoration: none;" title="Copy line to left (shift+left)"><img src="img/arrow_left.gif" alt="left arrow icon" /></a>'; 
    if(!leftsidemode) {
      getActionColumn(linenum).innerHTML += '<a href="javascript:void(0);" onclick="copyLine(getParentRowNum(this), false);" style="text-decoration: none;" title="Copy line to right (shift+right)"><img src="img/arrow_right.gif" alt="right arrow icon" /></a>'; 
    }
  }
  if(!leftsidemode && removeMarkup(rightLine.innerHTML) != right_ori.value.htmlchars()) {
    // edited right side
    getActionColumn(linenum).innerHTML += '<a href="javascript:void(0);" onclick="undoEdit(getParentRowNum(this), false);" title="Revert changes on right side (shift-u)"><img src="img/undo-right.gif" alt="revert arrow icon" /></a>';
    //tr.addClassName('edited');
  }
  if(getActionColumn(linenum).innerHTML == '') {
    // no change
    getActionColumn(linenum).innerHTML = '&nbsp;';
  }
  $("actions").value = actionHistory.join("\n");
}

function doAllRight() {
  var msg = "This will overwrite '" + left.getBaseName() + "' (left) \nwith '" + right.getBaseName() + "' (right) \nand complete the merge.\n\nDo you want to continue?";
  if(!leftsidemode) {
    msg = "This will \n\t1. Ignore your changes to '" + right.getBaseName() + "' (right), \n\t2. Delete '"
      + left.getBaseName() + "' (left), and \n\t3. Complete the merge.\n\nDo you want to continue?";
  }
  if(!confirm(msg)) {
    return false;
  }
  var url = "savefile.php";
  var params = "?method=useRightFile" + getRequestParams();
  var xhr = new Ajax.Request(url + params, {
    method: 'get',
    onSuccess: function(transport) {
      if(transport.readyState == 4 || transport.readyState == "complete") {
        if(transport.responseText.indexOf("ERROR") != 0) {
            $("helper").innerHTML = "Done!";
            window.location = returnto;
        }
        else {
            $("diff_table_c").innerHTML = '<pre class="error">' + transport.responseText.htmlchars() + '</pre>';
        }
      }
    },
    onLoading: function(transport) {
      if(transport.readyState != 4 && transport.readyState != "complete") {
        document.getElementById("diff_table_c").innerHTML = '<br/><br/><center><img src="img/spin.gif" alt="saving"/> Saving ...</center>';
      }
    }
  });
}

function doAllLeft() {
  if(!confirm("This will \n\t1. Ignore your changes to '" + left.getBaseName() + "' (left), \n\t2. Delete '" 
    + right.getBaseName() + "' (right), and \n\t3. Complete the merge.\n\nDo you want to continue?")) {
    return false;
  }
  var url = "savefile.php";
  var params = "?method=useLeftFile" + getRequestParams();
  var xhr = new Ajax.Request(url + params, {
    method: 'get',
    onSuccess: function(transport) {
      if(transport.readyState == 4 || transport.readyState == "complete") {
        if(transport.responseText.indexOf("ERROR") != 0) {
            $("helper").innerHTML = "Done!";
            window.location = returnto;
        }
        else {
            $("diff_table_c").innerHTML = '<pre class="error">' + transport.responseText.htmlchars() + '</pre>';
        }
      }
    },
    onLoading: function(transport) {
      if(transport.readyState != 4 && transport.readyState != "complete") {
        document.getElementById("diff_table_c").innerHTML = '<br/><br/><center><img src="img/spin.gif" alt="saving"/> Saving ...</center>';
      }
    }
  });
}

function getText(isleft) {
  var text = "";
  var lines = $("diff_table_body").getElementsByTagName("tr").length;
  for(var i = 0; i < lines; i++) {
    var stat = getRowStatus(i, isleft).value;
    if(stat == "d" || stat == 'od') continue;
    if(text != "") {
      text += "\n";
    }
    if(isleft) {
      text += removeMarkup(getLeftLine(i).innerHTML).unhtmlchars();
    }
    else {
      text += removeMarkup(getRightLine(i).innerHTML).unhtmlchars();
    }
  }
  return text;
}

function doSave(deleteother, which) {
  var isboth = false;
  var isleft = true;
  if(which == "left") {
    isleft = true;
  }
  else if(which == "right") {
    isleft = false;
  }
  else if(which == "both") {
    isboth = true;
    deleteother = false;
  }
  // save file ...
  if(isleft && deleteother) {
    if(!confirm("This will delete '" + right.getBaseName() + "' (right)\nand complete the merge.\n\nDo you want to continue?")) {
      return false;
    }
  }
  if(!isleft && deleteother) {
    if(!confirm("This will delete '" + left.getBaseName() + "' (left)\nand complete the merge.\n\nDo you want to continue?")) {
      return false;
    }
  }
  var url = "savefile.php";
  var params = "method=saveFile";
  if(isboth) {
    params = "method=saveFiles";
    // save both files
    params += getRequestParams();
    params += "&contentsleft=" + escape(getText(true));
    params += "&contentsright=" + escape(getText(false));
  }
  else {
    if(isleft) {
        params += getRequestParams();
    }
    else {
        params += getRequestParamsReverse();
    }
    params += "&deleteright=" + (deleteother ? "true" : "false") + "&contents=" + escape(getText(isleft));
  }
  var xhr = new Ajax.Request(url, {
    method: 'post',
    postBody: params,
    onSuccess: function(transport) {
      if(transport.readyState == 4 || transport.readyState == "complete") {
        var resp = transport.responseText;
        if(resp.indexOf("ERROR:") == 0) {
            $("diff_table_c").innerHTML = '<pre class="error">' + resp.htmlchars() + '</pre>';
        }
        else {
          if(deleteother) {
            window.location = returnto;
          }
          else {
            window.location.href = window.location.href;
          }
        }
      }
    },
    onLoading: function(transport) {
      if(transport.readyState != 4 && transport.readyState != "complete") {
        document.getElementById("diff_table_c").innerHTML = '<br/><br/><center><img src="img/spin.gif" alt="saving"/> Saving ...</center>';
      }
    }
  });
}

function getRequestParamsReverse() {
  var param = "&left=" + escape(right) + "&right=" + escape(left);
  param += '&rightPassword=' + escape($("txtPasswdLeftId").value);
  if(getRemoteHost(left) == getRemoteHost(right)) {
    // same host, same password
    $("hidPasswordType").value = "right";
    $("txtPasswdRightId").value = $("txtPasswdLeftId").value;
  }
  if($("hidPasswordType").value == "right") {
    param += '&leftPassword=' + escape($("txtPasswdRightId").value);
  }
  return param;
}

function getRequestParams() {
  var param = "&left=" + escape(left) + "&right=" + escape(right);
  param += '&leftPassword=' + escape($("txtPasswdLeftId").value);
  if(getRemoteHost(left) == getRemoteHost(right)) {
    // same host, same password
    $("hidPasswordType").value = "right";
    $("txtPasswdRightId").value = $("txtPasswdLeftId").value;
  }
  if($("hidPasswordType").value == "right") {
    param += '&rightPassword=' + escape($("txtPasswdRightId").value);
  }
  return param;
}

function sendPasswd() {
  var url = "getfiles.php";
  var param = '?method=getFiles' + getRequestParams();
  //$("hidPasswordType").value = "";
  var xhr_get_file = new Ajax.Request(url + param, {
    method: 'get',
    onLoading: function(transport) {
      // not ready yet!
      if(transport.readyState != 4 && transport.readyState != "complete") {
        document.getElementById("diff_table_c").innerHTML = '<br/><br/><center><img src="img/spin.gif" alt="loading"/> Loading ...</center>';
        $("passwd_c").style.display = "none";
      }
    },
    onSuccess: function(transport) {
      if(transport.readyState == 4 || transport.readyState == "complete") {
        // call getFiles again
        //alert(transport);
        $("passwd_c").style.display = "none";
        paintDiffTable(transport);
      }
    }
  });
}

function goback() {
  if(!readonly && confirm("This will abandon all your changes to the file(s) and return to the main page.\nContinue?")) {
    window.location = returnto;
  }
  return false;
}

function doReload() {
  if(!readonly && confirm("This will abandon all your changes to the file(s) and reload the diff.\nContinue?")) {
    window.location.href = window.location.href;
  }
  return false;
}

