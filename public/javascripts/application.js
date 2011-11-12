// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var show = false;
function AjaxShowHide()                                 //one arg - id of element
{
id = arguments[0];
if(show){                                               //e.g. we want to hide form
    Effect.SlideUp(id, { duration: 0.5 });
    show = !show;
    $('sf_lnk').text = "Show form";
    return false;}
else{
    Effect.SlideDown(id,{duration:0.5});
    show = !show;
    $('sf_lnk').text = "Hide form";
    return false; }                 
}

//for use in admin.rhtml template and correct dispay submenu
//include this AFTER prototype framework js declaration in your html, erb, haml file.
function ShowOneHideOthers(one_show)
{
	['sm1','sm2','sm3','sm4'].without(one_show).each(function(el, ind){
		Effect.Fade(el, {duration: 0.3});
	})
//	setTimeout(1);
	Effect.toggle(one_show, 'slide', {duration: 0.3})
//	Effect.multiple(['sm1','sm2','sm3','sm4'], function(el){Effect.toggle(el,'appear');});

}

//update these
	<!--

function getSel() 
 {
   var sel = '';
   if (window.getSelection) 
    {
      this.thisSel = window.getSelection() + '';
      sel = this.thisSel.toString();
    }
   else if (document.getSelection) sel = document.getSelection()+'';
   else if (document.selection) sel = document.selection.createRange().text;
   return "[quote]"+sel+"[/quote]\n";
 }							

//insert bbcodes in post message field						 
function insert_text(open, close)
{
	msgfield = (document.all) ? document.all.answer_message : document.forms['answer_form']['answer_message'];

	// IE support
	if (document.selection && document.selection.createRange)
	{
		msgfield.focus();
		sel = document.selection.createRange();
		sel.text = open + sel.text + close;
		msgfield.focus();
	}

	// Moz support
	else if (msgfield.selectionStart || msgfield.selectionStart == '0')
	{
		var startPos = msgfield.selectionStart;
		var endPos = msgfield.selectionEnd;

		msgfield.value = msgfield.value.substring(0, startPos) + open + msgfield.value.substring(startPos, endPos) + close + msgfield.value.substring(endPos, msgfield.value.length);
		msgfield.selectionStart = msgfield.selectionEnd = endPos + open.length + close.length;
		msgfield.focus();
	}

	// Fallback support for other browsers
	else
	{
		msgfield.value += open + close;
		msgfield.focus();
	}

	return;
}

function turnon_checkboxes(form)
{
	var inputs = form.getElementsByTagName('input');
	for(i=0;i<inputs.length;i++)
	{
		if(inputs[i].getAttribute("type") == 'checkbox')
		{
			inputs[i].checked = !inputs[i].checked;
		}
	}
	return false;	
}

