package lost.utils
{
	import flash.events.Event;
	
	import lost.utils.xml.XMLLoader;
	
	public dynamic class SettingsLoader extends XMLLoader
	{
		/* SINGLETON: design pattern
		- doel: 1 keer aanmaken van deze klasse
		- instance (static)
		- How? Private constructor? ==> Doesn't work!
		====> Dus "hack": forceren
		*/
		
		private static var instance:SettingsLoader;
		
		public function SettingsLoader(obj:Enforcer)
		{
			//nooit niemand van buitenaf kan dit instantieren
			//want enforcer object niet gekend is
	
		}
		//aanmaken van een instantie
		public static function getInstance():SettingsLoader {
			if(instance == null) {
				instance = new SettingsLoader(new Enforcer());
			}
			return instance;
		}
		override protected function completeHandler(event:Event):void {
			//aparte parsing van de settingsXML
			var settingsXML:XML = new XML(event.currentTarget.data);
			for each (var xmlNode:XML in settingsXML.setting) {
				this[xmlNode.@id] = xmlNode.toString();
			}
			dispatchEvent(new Event(XML_LOADED));
		}
	}
}

class Enforcer {
	
}