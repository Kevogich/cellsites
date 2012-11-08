// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {

	$('body').ajaxStart(function () {
		$("#container").append("<div id='ajax_div'>Processing.  Please wait... </div>");
	});
	$('body').ajaxStop(function () {
		$('#ajax_div').remove();
	});
	$('body').ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
		alert(jqXHR['status'] + ' ' + thrownError);
	});

	// fix breadcrumb on scroll
	var $win = $(window);
	var $breadcrumb_nav = $('.breadcrumb-nav');
	var breadcrumbTop = $('.breadcrumb-nav').length && $('.breadcrumb-nav').offset().top - 40;
	var isFixed = 0;

	processScroll();

	function processScroll() {
		var i, scrollTop = $win.scrollTop();
		if (scrollTop >= breadcrumbTop && !isFixed) {
			isFixed = 1;
			$breadcrumb_nav.addClass('breadcrumb-nav-fixed')
		} else if (scrollTop <= breadcrumbTop && isFixed) {
			isFixed = 0;
			$breadcrumb_nav.removeClass('breadcrumb-nav-fixed');
		}
	}

	$win.scroll(function () {
		processScroll();
	});

	//clone sizing
	$(".clone_sizing").click(function () {
		var tag = prompt("Please enter tag")

		if (tag != null && tag != "") {
			$.ajax({
				url:$(this).attr('href'),
				dataType:'json',
				data:{'tag':tag},
				success:function (resp) {
					if (resp.error) {
						alert(resp.msg)
					}
					else {
						window.location = resp.url
					}
				}
			});
		}
		else {
			alert("Tag is required to create new sizing")
		}
		return false
	});

	$('.file-wrapper input[type=file]').bind('change focus click', SITE.fileInputs);

	$("a[rel=popover]").popover();

	if($('a.sizing_status_btn').length) {
		$('a.sizing_status_btn').colorbox({});
	}
});

function deleted_tr(tr) {
	$(tr).addClass('deleted_tr');
	$(tr).find('input,select').attr('readonly', true);
	//$(tr).find('select,input[type=text],input[type=radio]').val('');
}

// select table row or column
//http://programanddesign.com/js/jquery-select-table-column-or-row/
$.fn.row = function (i) {
	return $('tr:nth-child(' + (i + 1) + ') td', this);
}
$.fn.column = function (i) {
	return $('tr td:nth-child(' + (i + 1) + ')', this);
}
//simple method for form validation
//to validate input fields under a given tab
//fields should be input boxes and child nodes of a given tab
//give class "required" for the fields to be validated
//use as $("tab id").validateTab()
$.fn.validateTab = function (options) {
	var valid = true;
	var blank_fields = false;
	this.find(":input[type='text'].required").each(function () {
		if ($(this).val() == "") {
			blank_fields = true;
			valid = false;
			$(this).css({"border":"1px solid red"});
		}
	});
	if (blank_fields) {
		alert("Please enter required values!")
	}
	;
	return valid
};

$.fn.serializeObject = function () {
	var o = {};
	var a = this.serializeArray();
	$.each(a, function () {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

/* file upload */
var SITE = SITE || {};
SITE.fileInputs = function () {
	var $this = $(this),
		$val = $this.val(),
		valArray = $val.split('\\'),
		newVal = valArray[valArray.length - 1],
		$button = $this.siblings('.button'),
		$fakeFile = $this.siblings('.file-holder');
	if (newVal !== '') {
		//$button.text('Photo Chosen');
		if ($fakeFile.length === 0) {
			$button.text(newVal + ' is Selected');
			//$button.after('<span class="file-holder">' + newVal + '</span>');
		} else {
			$fakeFile.text(newVal);
		}
	}
};

/* Pipings */
$('form.piping_form .btn_save_piping').live('click', function(){
  save_piping_form();
  return false;
});

$('form.piping_form .btn_close_piping').live('click', function(){
  save_piping_form();
  return false;
});

function save_piping_form() {
  if(validate_piping_form()) {
    $('form.piping_form').submit();
  }
}

$('form.piping_form a.remove_piping_row').live('click', function(){
  var tr = $(this).parents('tr');
  tr.hide();
  $(this).next().val(true);

  //reorder sequence
  $('.piping_table span.sequence_no:visible').each(function(index){
    $(this).text(index+1);
    $(this).nextAll('.piping_sequence_no').val(index+1);
  });

  return false;
});

$('.piping_form_link').live('click', function(){
  var pipeable_id = $(this).attr('data_pipeable_id');
  var pipeable_type = $(this).attr('data_pipeable_type');
  var pipeable_url = "/admin/pipings?pipeable_id="+ pipeable_id + "&pipeable_type=" + pipeable_type;

  if(pipeable_id == "" || pipeable_id == undefined) {
    return false;
  }

  $.colorbox({
    href: pipeable_url,
    width:'100%',
    height:'100%'
  });

  return false;
});


/* End pipings */