(function(_scope){
	
	/*
	 * pi.comet.js
	 * Comet Plug-in for pi.js
	 * 1.2
	 * Azer Koçulu <http://azer.kodfabrik.com>
	 * http://pi.kodfabrik.com
	 */
	
	_scope.comet = pi.base.extend({
		"$Init":function(_name,_callback,_disconnect){
			this.environment.setName(_name||"PIComet");
			this.environment.setMethod(pi.env.ie?3:pi.env.opera?2:1);
			this.environment.setTunnel(
				this.environment.getMethod()==3?new ActiveXObject("htmlfile"):
				this.environment.getMethod()==2?document.createElement("event-source"):
				new pi.xhr
			);
			this.event.push = _callback||new Function;
			this.event.disconnect = _disconnect||new Function;
			return this;
		},
		"checkFrameState":function(){
			if(this.environment.getTunnel().getElementById(this.environment.getName() + 'FrameBody').readyState=="loading"){
				setTimeout(this.checkFrameState.curry(this),500);
			} else {
				this.environment.getTunnel().parentWindow.PIComet.event.disconnect();
				this.environment.getTunnel().getElementById(this.environment.getName() + 'FrameBody').parentNode.removeChild(
					this.environment.getTunnel().getElementById(this.environment.getName() + 'FrameBody')
				);
				this.environment._setTunnel(null);
			}
		},
		"abort":function(){
			switch(this.environment.getMethod()){
				case 1:
					this.environment.getTunnel().abort();
					break;
				case 2:
					document.body.removeChild(this.environment.getTunnel());
					break;
				case 3:
					this.environment.getTunnel().body.innerHTML="<iframe src='about:blank'></iframe>";
			}
		},
		"send":function(){
			switch(this.environment.getMethod()){
				case 1:
					this.environment.getTunnel().send();
					break;
				case 2:
					document.body.appendChild(this.environment.getTunnel());
					this.environment.getTunnel().addEventListener(this.environment.getName(),this.event.change,false);
					break;
				case 3:
					this.environment.getTunnel().open();
					this.environment.getTunnel().write("<html><body></body></html>");
					this.environment.getTunnel().close();
					this.environment.getTunnel().parentWindow.PIComet = this;
					this.environment.getTunnel().body.innerHTML="<iframe id='{0}' src='{1}'></iframe>".format(this.environment.getName() + 'FrameBody',this.environment.getUrl());
					setTimeout(this.checkFrameState.curry(this), 500);
			};
			return this;
		},
		"environment":{
			"_byteOffset":0, "_name":"", "_tunnel":null, "_method":"", "_url":"",
			"setTunnel":function(_value){
				if(this.getMethod()==1){
					_value.environment.
					addData("PICometMethod","1").environment.
					addCallback([3],this._parent_.event.change).environment.
					addCallback([4],this._parent_.event.disconnect.curry(this._parent_)).environment.
					setCache(false);
				}
						
				_value._cometApi_ = this._parent_;
				this._setTunnel(_value);
				return this._parent_;
			},
			"setUrl":function(_value){
				if(this.getMethod()>1){
					_value = "{0}{1}PICometMethod={2}&PICometName={3}".format(_value,_value.search("\\?")>-1?"&":"?",this.getMethod(),this.getName(),Math.round(Math.random()*1000));
					if(this.getMethod()==2)
						this.getTunnel().setAttribute("src",_value);
				} else
					this.getTunnel().environment.setUrl(_value);
				this._setUrl(_value);
				return this._parent_;
			}
		},
		"event":{
			"change":function(){
				if (this._cometApi_.environment.getMethod() == 2)
					this._cometApi_.event.push(arguments[0].data);
				else {
					var buffer = this.environment.getApi().responseText;
					var newdata = buffer.substring(this._cometApi_.environment.getByteOffset());
					while (true) {
						var start = newdata.indexOf("<comet>", end), end = newdata.indexOf("</comet>", start);
						if (end < 0 || start < 0) 
							break;
						this._cometApi_.event.push(newdata.substring(start + 7, end));
					};
					this._cometApi_.environment.setByteOffset(newdata.length + this._cometApi_.environment.getByteOffset());
				}
			},
			"disconnect":new Function,
			"push":new Function
		}
	});
	
	_scope.comet.get = function(_url,_listener,_disconnect){
		return new _scope.comet("PIComet"+Number(new Date()),_listener,_disconnect).environment.setUrl(_url).send();
	};
	
	_scope.comet.version = [1.1,2008091000];
})(pi);