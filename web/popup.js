var b2rPopup = {

	POPUP_DELAY: 200,

	startup: function(){
		setTimeout(function(){
//			b2rPopup.resPopup.init();
			b2rPopup.imagePopup.init();
			b2rPopup.idPopup.init();
			b2rPopup.videoPopup.init();
		}, 0);
	},


	mouseOut: function(aEvent){
		var targetNode = aEvent.target;
		if(targetNode._popupTimeout){
			clearTimeout(targetNode._popupTimeout);
			targetNode._popupTimeout = null;
		}
	},


	xpathEvaluate: function(aXpath){
		var result = new Array();
/*		var xpathResult = document.evaluate(aXpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
		for(var i=0; i<xpathResult.snapshotLength; i++){
			var node = xpathResult.snapshotItem(i);
			result.push(node);
		}*/
		return result;
	},


	showPopup: function(aEvent, aContentNode, aClassName){
		var targetNode = aEvent.target;
		if(targetNode._popupTimeout){
			clearTimeout(targetNode._popupTimeout);
		}
		targetNode._popupTimeout = setTimeout(b2rPopup._showPopupDelay, b2rPopup.POPUP_DELAY,
				aEvent.pageX, aEvent.pageY, aContentNode, aClassName);
	},

	_showPopupDelay: function(aPageX, aPageY, aContentNode, aClassName){
		var popup = document.createElement("div");
		popup.className = aClassName || "popup";

		popup.onmouseout = function(aEvent){
			if(aEvent.pageX <= this.offsetLeft ||
					aEvent.pageY <= this.offsetTop ||
					aEvent.pageX >= this.offsetLeft + this.offsetWidth ||
					aEvent.pageY >= this.offsetTop + this.offsetHeight){
				this.onmouseout = null;
				document.body.removeChild(this);
			}
		};

		popup.appendChild(aContentNode);
		document.body.appendChild(popup);

		if(popup.clientWidth > window.innerWidth - 40){
			popup.style.width = (window.innerWidth - 40) + "px";
		}
		if(popup.clientHeight > window.innerHeight - 20){
			popup.style.height = (window.innerHeight - 20) + "px";
		}

		var winPageRight = window.innerWidth;
		var winPageBottom = window.innerHeight + window.window.scrollY;
		var x = winPageRight - (popup.clientWidth + aPageX);
		var y = winPageBottom - (popup.clientHeight + aPageY);

		if(x > 0){
			popup.style.left = (aPageX - 10) + "px";
		}else{
			popup.style.left = "auto";
			popup.style.right = "10px";
		}
		if(y > 0){
			popup.style.top = (aPageY - 10) + "px";
		}else{
			popup.style.top = (winPageBottom - popup.clientHeight - 10) + "px";
		}
	}

};


b2rPopup.resPopup = {

	local: function(popup, top_id, bottom_id){
		popup.empty();
		for(var i = top_id; i <= bottom_id; i++){
			res = $("#_" + i)
			popup.append(res.clone(true));
		}
	},
	
	
	remote: function(popup, top_id, bottom_id){
		popup.load("./res_anchor?picker=" + top_id + "-" + bottom_id + " div[class=thread_body]");
	},
	
	
	mouseOver: function(aEvent, top_id, bottom_id, popupFunc){
		if(aEvent.target.popuping){
			return;
		}
		
		var targetNode = aEvent.target;
		var relatedNode = aEvent.relatedTarget;
		if(relatedNode &&
				(relatedNode.className=="popup" || relatedNode.parentNode.className=="popup") &&
				!targetNode._popupTimeout){
			return;
		}

		var startRes = 0;
		var endRes = 0;
		if(targetNode.text.match(/>>?(\d{1,4})-(\d{1,4})/)){
			startRes = parseInt(RegExp.$1);
			endRes = parseInt(RegExp.$2);
		}else if(targetNode.text.match(/>>?(\d{1,4})/)){
			startRes = parseInt(RegExp.$1);
			endRes = startRes;
		}
		
		var popup = $("<div class='popup'>Loading</div>");
		$(aEvent.target).after(popup);
		popup.left = aEvent.pageX;
		popup.top = aEvent.pageY;
		$(document).click(function(){
			popup.remove();
			aEvent.target.popuping = false;
		});
		popupFunc(popup, top_id, bottom_id);
		aEvent.target.popuping = true;
	},


	createContent: function(aStart, aEnd){
		var content = document.createDocumentFragment();

		var resNode = document.getElementById("_" + aStart);
		if(!resNode) return null;
		if(aStart < aEnd){
			if(aStart < 1) aStart = 1;
			if(aEnd > 1000) aEnd = 1000;
			const POPUP_LIMIT = 20;

			if((aEnd - aStart) > POPUP_LIMIT) aStart = aEnd - POPUP_LIMIT;

			for(var i = aStart; i<=aEnd; i++){
				resNode = document.getElementById("_" + i);
				if(!resNode) break;
				content.appendChild(b2rPopup.resPopup.getCloneNode(resNode));
			}
		}else{
			content.appendChild(b2rPopup.resPopup.getCloneNode(resNode));
		}
		if(!content.firstChild) return null;
		return content;
	},


	getCloneNode: function(aNode){
		aNode = aNode.cloneNode(true);
		if(aNode.id) aNode.id = "";
		var elements = aNode.getElementsByTagName("*");
		for(var i=0; i<elements.length; i++){
			if(elements[i].id) elements[i].id = "";
		}
		aNode.style.display = "block";
		return aNode;
	}

};


b2rPopup.imagePopup = {

	init: function(){
		var imageLinks = document.getElementsByTagName("a");
		for(var i = 0; i < imageLinks.length; i++){
			var imageLink = imageLinks[i];
			if(imageLink.className != "image"){
				continue;
			}
			imageLink.setAttribute("onmouseover", "b2rPopup.imagePopup.mouseOver(event)");
			imageLink.setAttribute("onmouseout", "b2rPopup.mouseOut(event)");
		}
	},

	mouseOver: function(aEvent){
		var targetNode = aEvent.target;
		var relatedNode = aEvent.relatedTarget;
		if(relatedNode && (relatedNode.className=="imagePopup" ||
				relatedNode.parentNode.className=="imagePopup") &&
					!targetNode._popupTimeout){ return; }

		var popup = document.createElement("div");
		popup.style.backgroundColor = "white";

		var a = document.createElement("a");
		a.target = "_blank";
		a.href = targetNode.href;
		a.innerHTML = "open";
		popup.appendChild(a);

		var br = document.createElement("br");
		popup.appendChild(br);

		var image = document.createElement("img");
		image.style.width = "120px";
		image.style.borderStyle = "none";
		image.src = targetNode.href;
		image.onclick = function(aEvent){
			var targetNode = aEvent.originalTarget;
			targetNode.style.width = (targetNode.style.width == "") ? "120px" : "";
		}
		popup.appendChild(image);

		b2rPopup.showPopup(aEvent, popup, "imagePopup");
	}

};


b2rPopup.idPopup = {

	init: function(){
		var xpath = "descendant::span[@class='resID']|descendant::span[@class='resMesID']";
		for(var node in b2rPopup.xpathEvaluate(xpath)){
			node.setAttribute("onmouseover", "b2rPopup.idPopup.mouseOver(event)");
			node.setAttribute("onmouseout", "b2rPopup.mouseOut(event)");
		}
	},

	mouseOver: function(aEvent){
		var targetNode = aEvent.target;
		var resID = "";
		if(targetNode.className.substring(0, 3) == "id_"){
			resID = targetNode.className.substring(3);
		}else{
			resID = targetNode.className.substring(6);
		}
		if(resID == "") return;
		if(resID.substring(0, 3) == "???") return;

		var xpathCategoryText = "descendant::span[@class=\'id_" + resID + "\']/../../..";
		var xpathResult = document.evaluate(xpathCategoryText, document,
			null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

		var resNumbers = new Array();
		for (var i = 0; i < xpathResult.snapshotLength; i++){
			var node = xpathResult.snapshotItem(i);
			resNumbers.push(parseInt(node.id.substring(3)));
		}

		var currentResNumber = parseInt(targetNode
					.parentNode.parentNode.parentNode.id.substring(3));
		resNumbers = resNumbers.filter(function(aElement, aIndex, aArray){
			return aElement != currentResNumber;
		});
		if(resNumbers.length == 0) return;

		var start = 0;
		if(resNumbers.length > 10) start = resNumbers.length - 10;

		var content = document.createDocumentFragment();
		if(start > 0){
			var p = document.createElement("p");
			p.appendChild(document.createTextNode(start + "mojibake"));
			content.appendChild(p);
		}
		for(i=start; i<resNumbers.length; i++){
			var resNode = document.getElementById("res" + resNumbers[i]);
			if(!resNode) break;
			content.appendChild(b2rPopup.idPopup.getCloneNode(resNode));
		}
		if(!content.firstChild) return;

		b2rPopup.showPopup(aEvent, content);
	},


	getCloneNode: function(aNode){
		aNode = aNode.cloneNode(true);
		if(aNode.id) aNode.id = "";
		var elements = aNode.getElementsByTagName("*");
		for(var i=0; i<elements.length; i++){
			if(elements[i].id) elements[i].id = "";
			if(elements[i].className.substring(0, 3) == "id_") elements[i].className = "";
		}
		return aNode;
	}

};


b2rPopup.videoPopup = {

	init: function(){
		var xpathYoutube = "descendant::a[@class='outLink'][contains(@href, '.youtube.com/watch')]";
		var xpathStage6 = "descendant::a[@class='outLink'][contains(@href, 'http://stage6.divx.com/content/show')]";
		var xpathStage6m = "descendant::a[@class='outLink'][contains(@href, 'http://stage6.divx.com/members')]";
		var xpathStage6c = "descendant::a[@class='outLink'][contains(@href, 'http://stage6.client.jp/#')]";
		var xpath = xpathYoutube +"|"+ xpathStage6 +"|"+ xpathStage6m +"|"+ xpathStage6c;

		for(var node in b2rPopup.xpathEvaluate(xpath)){
			node.setAttribute("onmouseover", "b2rPopup.videoPopup.mouseOver(event)");
			node.setAttribute("onmouseout", "b2rPopup.mouseOut(event)");
		}
	},

	mouseOver: function(aEvent){
		var targetNode = aEvent.target;
		var relatedNode = aEvent.relatedTarget;
		if(relatedNode && relatedNode.className == "imagePopup") return;

		var url = targetNode.href;
		var content;
		if(url.indexOf(".youtube.com")!=-1 && url.match(/v=([^\&]+)/)){
			content = b2rPopup.videoPopup.createYoutubeContent(RegExp.$1);
		}else if(url.indexOf("stage6.divx.com")!=-1 && url.match(/content_id=([^\&]+)/)){
			content = b2rPopup.videoPopup.createStage6Content(RegExp.$1);
		}else if(url.indexOf("stage6.divx.com")!=-1 && url.match(/videos\/([^\&]+)/)){
			content = b2rPopup.videoPopup.createStage6Content(RegExp.$1);
		}else if(url.indexOf("http://stage6.client.jp/#")!=-1 && url.match(/\/#([^\&]+)/)){
			content = b2rPopup.videoPopup.createStage6Content(RegExp.$1);
		}

		if(content){
			b2rPopup.showPopup(aEvent, content, "imagePopup");
		}
	},


	createYoutubeContent: function(aVideoID){
		var videoURL = "http://www.youtube.com/v/" + aVideoID
		var videoObject = document.createElement("object");
		videoObject.setAttribute("data", videoURL);
		videoObject.setAttribute("type", "application/x-shockwave-flash");
		videoObject.setAttribute("width", "320");
		videoObject.setAttribute("height", "260");
		return videoObject;
	},


	createStage6Content: function(aVideoID){
		var url = "http://stage6.divx.com/content/show?content_id=" + aVideoID + ".divx";
		var thumbnailURL = "http://images.stage6.com/videos/" + aVideoID + ".jpg";

		var link = document.createElement("a");
		link.setAttribute("href", url);
		link.setAttribute("target", "_blank");
		var image = document.createElement("img");
		image.setAttribute("src", thumbnailURL);
		image.style.width = "320px";
		image.style.borderStyle = "none";
		link.appendChild(image);
		return link;
	}

};
