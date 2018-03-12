package
{
	public class Player
	{
		private var _id:int;
		private var _name:String;
		private var _score:String;
		
		public function Player(id:int,name:String,score:String)
		{
			_id = id
			_name = name
			_score = score
		}

		public function get id():int
		{
			return _id;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get score():String
		{
			return _score;
		}

		public function set score(value:String):void
		{
			_score = value;
		}

	}
}