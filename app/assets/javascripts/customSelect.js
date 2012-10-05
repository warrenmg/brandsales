(function(jq){
 jq.fn.extend({
 
 	customStyle : function(options) {
	  if(!jq.browser.msie || (jq.browser.msie&&jq.browser.version>6)){
	  return this.each(function() {
	  
			var currentSelected = jq(this).find(':selected');
			jq(this).after('<span class="customStyleSelectBox"><span class="customStyleSelectBoxInner">'+currentSelected.text()+'</span></span>').css({position:'absolute', opacity:0,fontSize:jq(this).next().css('font-size')});
			var selectBoxSpan = jq(this).next();
			var selectBoxWidth = parseInt(jq(this).width()) - parseInt(selectBoxSpan.css('padding-left')) -parseInt(selectBoxSpan.css('padding-right'));			
			var selectBoxSpanInner = selectBoxSpan.find(':first-child');
			selectBoxSpan.css({display:'inline-block'});
			selectBoxSpanInner.css({width:selectBoxWidth, display:'inline-block'});
			var selectBoxHeight = parseInt(selectBoxSpan.height()) + parseInt(selectBoxSpan.css('padding-top')) + parseInt(selectBoxSpan.css('padding-bottom'));
			jq(this).height(selectBoxHeight).change(function(){
				// selectBoxSpanInner.text(jq(this).val()).parent().addClass('changed');   This was not ideal
			selectBoxSpanInner.text(jq(this).find(':selected').text()).parent().addClass('changed');
				// Thanks to Juarez Filho & PaddyMurphy
			});
			
	  });
	  }
	}
 });
})(jQuery);

(function(jq){
 jq.fn.extend({
 
 	customStyle1 : function(options) {
	  if(!jq.browser.msie || (jq.browser.msie&&jq.browser.version>6)){
	  return this.each(function() {
			var currentSelected = jq(this).find(':selected');
			jq(this).after('<span class="customStyleSelectBox1"><span class="customStyleSelectBoxInner">'+currentSelected.text()+'</span></span>').css({position:'absolute', opacity:0,fontSize:jq(this).next().css('font-size')});
			var selectBoxSpan = jq(this).next();
			var selectBoxWidth = parseInt(jq(this).width()) - parseInt(selectBoxSpan.css('padding-left')) -parseInt(selectBoxSpan.css('padding-right'));			
			var selectBoxSpanInner = selectBoxSpan.find(':first-child');
			selectBoxSpan.css({display:'inline-block'});
			selectBoxSpanInner.css({width:selectBoxWidth, display:'inline-block'});
			var selectBoxHeight = parseInt(selectBoxSpan.height()) + parseInt(selectBoxSpan.css('padding-top')) + parseInt(selectBoxSpan.css('padding-bottom'));
			jq(this).height(selectBoxHeight).change(function(){
				// selectBoxSpanInner.text(jq(this).val()).parent().addClass('changed');   This was not ideal
			selectBoxSpanInner.text(jq(this).find(':selected').text()).parent().addClass('changed');
				// Thanks to Juarez Filho & PaddyMurphy
			});
			
	  });
	  }
	}
 });
})(jQuery);