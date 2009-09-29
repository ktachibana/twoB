/*
  bbs2chreader �ł��ځ[��o�^���s���� document �I�u�W�F�N�g�� b2raboneadd �C�x���g����������
  �C�x���g�n���h���� aEvent ��������A���ځ[�񂳂ꂽ������Ƃ��̃^�C�v���擾�ł���
    aEvent.detail : ���ځ[��^�C�v( b2rIAboneManager.ABONE_TYPE_XXX )
    aEvent.sourceEvent.type : ���ځ[�񂳂ꂽ������
*/
var b2rAboneHandler = {

	startup: function(){
		document.addEventListener("b2raboneadd", b2rAboneHandler, false);

		this._aboneHTML = <>
			<dt class="resHeader">
				<span class="resNumber">XXX</span>
				<span class="resName">ABONE</span>
				[<span class="resMail">ABONE</span>]
				Date:<span class="resDate">ABONE</span>
				<span class="resID"><span class="id_<ID/>">ID:</span></span>
				Be:<span class="resBeID"><BEID/></span>
			</dt>
			<dd class="resBody">ABONE</dd>
		</>.toString();
	},

	handleEvent: function(aEvent){
		var aboneWord = aEvent.sourceEvent.type;
		switch(aEvent.detail){
			case 0:    // Components.interfaces.b2rIAboneManager.ABONE_TYPE_NAME
				var xpath = "descendant::span[@class='resName']";
				for(let [index, node] in Iterator(b2rAboneHandler.xpathEvaluate(xpath))){
					var textContent = node.textContent;
					if(textContent.indexOf(aboneWord) != -1){
						node.parentNode.parentNode.innerHTML = b2rAboneHandler._aboneHTML;
					}
				}
				break;

			case 1:    // Components.interfaces.b2rIAboneManager.ABONE_TYPE_MAIL
				var xpath = "descendant::span[@class='resMail']";
				for(let [index, node] in Iterator(b2rAboneHandler.xpathEvaluate(xpath))){
					var textContent = node.textContent;
					if(textContent.indexOf(aboneWord) != -1){
						node.parentNode.parentNode.innerHTML = b2rAboneHandler._aboneHTML;
					}
				}
				break;

			case 2:    // Components.interfaces.b2rIAboneManager.ABONE_TYPE_ID
				var xpath = "descendant::span[@class='resID']/span";
				for(let [index, node] in Iterator(b2rAboneHandler.xpathEvaluate(xpath))){
					var textContent = node.className.substring(3);
					if(textContent.indexOf(aboneWord) != -1){
						node.parentNode.parentNode.parentNode.innerHTML = b2rAboneHandler._aboneHTML;
					}
				}
				break;

			case 3:    // Components.interfaces.b2rIAboneManager.ABONE_TYPE_WORD
				var xpath = "descendant::dd[@class='resBody']";
				for(let [index, node] in Iterator(b2rAboneHandler.xpathEvaluate(xpath))){
					var textContent = node.textContent;
					if(textContent.indexOf(aboneWord) != -1){
						node.parentNode.innerHTML = b2rAboneHandler._aboneHTML;
					}
				}
				break;
		}
	},

	xpathEvaluate: function(aXpath){
		var result = new Array();
		var xpathResult = document.evaluate(aXpath, document, null,
				XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
		for(let i=0; i<xpathResult.snapshotLength; i++){
			var node = xpathResult.snapshotItem(i);
			result.push(node);
		}
		return result;
	}
};