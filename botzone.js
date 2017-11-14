
function showDebug() {
  window.top.debugWindow =
      window.open("",
                  "Debug",
                  "left=0,top=0,width=300,height=700,scrollbars=yes,"
                  +"status=yes,resizable=yes");
  window.top.debugWindow.opener = self;
  // open the document for writing
  window.top.debugWindow.document.open();
  window.top.debugWindow.document.write(
      "<HTML><HEAD><TITLE>Debug Window</TITLE></HEAD><BODY><PRE>\n");
}

// If the debug window exists, then write to it
function debug(text) {
  if (window.top.debugWindow && ! window.top.debugWindow.closed) {
    window.top.debugWindow.document.write(text+"\n");
  }
}

function itemcheck(item)
{
    var itemset = document.getElementsByName(item);
    var ok = true;
    var num = itemset.length;
    if (num == 0) { return true; }
    var kind = itemset[0].type;
    if (kind == "text" || kind == "textarea")
	{
	    ok = (set[0].value != "");
	}
    else if (kind == "radio" || kind =="checkbox")
	{
	    var check = false;
	    for (r = 0; r < itemset.length; r++)
		{
		    if (itemset[r].checked)
			{
			    check = true;
			    break;
			}
		}
	    ok = check;
	}     
    else if (kind == "select-one")
	{
	    ok = (itemset[0].selectedIndex > 0);
	}
    if (!ok)
	{
	    itemset[0].focus();
	}
    return (ok);
}

function formcheck(whichform)
{
    // showDebug();	
    var buf = "";
    var all = whichform.elements["itemlist"].value;
    var temp = new Array();
    var temp2 = new Array();
    temp = all.split(",");	
    
    for (t in temp)
	{
	    temp2 = temp[t].split(":");
	    var num = temp2[0];
	    var item = temp2[1];

	    if (! itemcheck (item) || ! itemcheck (item + "[]"))
		{
		    alert ("Please answer question " + num);
		    return (false);
		}
	}
    return (true);
}


function beeperAdd (id, itemid)
{
    var input = document.getElementsByName("*" + itemid)[0];
    input.value = input.value + id + ".";    
}

function beeperRemove (id, itemid)
{
    var input = document.getElementsByName("*" + itemid)[0];
    input.value = input.value.replace (id + ".", "");

}

function toggle(id, itemid)
{
  var item = document.getElementById(id);
  var idparts = id.split(":");

  if (item.className == "beeper")
  {
      item.className = "none";
      beeperRemove (idparts[1], itemid);
  }
  else
  {
      item.className = "beeper";
      beeperAdd (idparts[1], itemid);
  }
}

