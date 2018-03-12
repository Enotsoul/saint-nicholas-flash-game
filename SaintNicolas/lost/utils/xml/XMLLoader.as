package lost.utils.xml
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XMLLoader extends EventDispatcher
	{
		public var _data:XML;
		public var _feed:String,url:String;
		public static const XML_LOADED:String = "xmlLoaded";
		public static const XML_FAILED:String = "xmlFailed";
		public function XMLLoader()
		{
			
		}

		public function get data():XML { return _data; }
		public function set data(value:XML):void { _data = value; }
		public function get feed():String { return _feed; }
		
		public function load(urlToLoad:String):void {
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			ldr.addEventListener(Event.COMPLETE,completeHandler);
			var req:URLRequest = new URLRequest(urlToLoad);
			ldr.load(req);
			url = urlToLoad
		}
		protected function errorHandler(event:IOErrorEvent):void {
			trace("FOUT BIJ INLEZEN!")
			load(url);
			//var eventje:Event = new Event(XML_FAILED);
			//dispatchEvent(eventje);
		}
		protected function completeHandler(event:Event):void {
			_data = new XML(event.currentTarget.data);
			trace("GELUKT!");
			dispatchEvent(new Event(XML_LOADED));
		}
	}
}