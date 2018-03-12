package
{
	import flash.display.MovieClip;

	public class Present
	{
		private var _name:String;
		private var _type:MovieClip;
		private var _score:int;
		
		public function Present(name:String,type:MovieClip,score:int)
		{
			this._name = name
			this._type = type
			this._score = score
		}

		public function get score():int
		{
			return _score;
		}

		public function set score(value:int):void
		{
			_score = value;
		}

		public function get type():MovieClip
		{
			return _type;
		}

		public function set type(value:MovieClip):void
		{
			_type = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

	}
}