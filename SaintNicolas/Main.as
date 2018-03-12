package
{
	import com.greensock.TweenLite;
	import com.greensock.core.PropTween;
	
	import fl.motion.FunctionEase;
	import fl.transitions.easing.None;
	import fl.transitions.easing.Regular;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	
	import lost.utils.SettingsLoader;
	import lost.utils.xml.XMLLoader;
	
	public class Main extends MovieClip
	{
		private var catcher:Catcher;
		private var thrower:SaintNicolas;
		private var tmr:Timer;
		private var oldPosX:Number = 0;
		private var presentContainer:MovieClip;
		private var menu:Menu;
		
		private var intro:Intro = new Intro();
		private var levelFinished:LevelFinished = new LevelFinished();
		private var gameFinished:GameFinished = new GameFinished();
		private var showHighscore:ShowHighScores = new ShowHighScores();
		private var instructions:Instructions = new Instructions();
		
		private var highscore:int = 0;
		private var lifes:int=0;
		private var catches:int= 0;
		private var toCatch:int = 0;
		private var level:int = 0;
		private var  time:int;
		
		private var conn:NetConnection;
		private var playerArray:Array = [];
		private var settings:SettingsLoader;
		private var presents:Array;
		private var infoTable:InfoTable;
		
		//font stuff
		private var format:TextFormat = new TextFormat();
		private	var titleField:TextField = new TextField();
		private var myFont:TheFont = new TheFont();
		//Game status & stuff
		private var paused:Boolean = false
		private var gameIsRunning:Boolean = false	
		private var isInstructing:Boolean = false;
		
		private var music:Sound = new Sound(new URLRequest("assets/jinglebells.mp3"));
		private var sc:SoundChannel;
		private var isPlaying:Boolean = false;


		public function Main()
		{
			
			addChild(showHighscore)
			addChild(gameFinished)
			addChild(levelFinished)
			addChild(instructions)
			
			showHighscore.visible =false
			gameFinished.visible =false
			levelFinished.visible =false
			instructions.visible = false
				
			showHighscore.addEventListener(MouseEvent.CLICK,showMenu);
				
			levelFinished.addEventListener(MouseEvent.CLICK,nextLevel);
			gameFinished.addEventListener(MouseEvent.CLICK,gameEnded);
			//add the music.. button
			
			soundbtn.addEventListener(MouseEvent.CLICK, ToggleMusic);
			soundbtn.buttonMode = true;
			//stop 
			stage.addEventListener(KeyboardEvent.KEY_DOWN,function (key:KeyboardEvent) {
			//	trace("You pressed "+ key.keyCode);
				if (key.keyCode == 80 && gameIsRunning && !isInstructing) {
					trace("Game was paused!")
					paused = !paused;
					instructions.removeEventListener(MouseEvent.CLICK,instructionClickHandler);
					if (paused) {
						stop();
						tmr.stop();
						
						TweenLite.killTweensOf(thrower);
						
						for each(var present:Present in presentContainer) {
							TweenLite.killTweensOf(present.type)
							presentContainer.removeChild(present.type);
						}
						
						instructions.visible = true
						showTextBox("Game paused.. press P to resume");
						titleField.x = (stage.stageWidth -titleField.width)/2
						titleField.y = (stage.stageHeight -titleField.height)/2
					} else {
						instructions.visible = false
						play();
						tmr.start()
					}
				}
			})
			//Load the settings...
			settings =  SettingsLoader.getInstance();
			settings.addEventListener(XMLLoader.XML_LOADED,settingsLoadedHandler)
			settings.load("assets/settings.xml")
			
			//INTRO
			intro.y = intro.height/2;
			intro.x = (stage.stageWidth-intro.width);
			addChild(intro);
			setTimeout(function() {
				//start the music just before you remove the intro 
				sc = music.play();
				isPlaying = true;
				
				removeChild(intro);
				//MENU
				menu = new Menu();
				addChild(menu);
				menu.x = (stage.stageWidth-menu.width)
				menu.y = (stage.stageHeight-menu.height)
				
				//Click Handling for the buttons
				menu.newGame.addEventListener(MouseEvent.CLICK,menuClick);
				menu.instructions.addEventListener(MouseEvent.CLICK,menuClick);
				menu.highscores.addEventListener(MouseEvent.CLICK,menuClick);
				
				menu.newGame.buttonMode = true
				menu.instructions.buttonMode = true
				menu.highscores.buttonMode = true
					
			},2500);			
			//textfield font initialisation
			format.color = 0x00FF00;
			format.size  = 20;
			format.font = myFont.fontName

			//embed
			titleField.embedFonts = true;
			titleField.selectable  = false
			titleField.defaultTextFormat = format; //this will set it correctly
			titleField.autoSize = TextFieldAutoSize.LEFT;
			instructions.addChild(titleField)

				
			//selectables to false
			showHighscore.scoreList.selectable  = false
			showHighscore.nameList.selectable  = false

		}
		
		private function settingsLoadedHandler(event:Event):void {
			trace("ROOT: " + settings.server);
			//Initialise connection
			conn = new NetConnection()
			//connect to the gateway
			try {
				conn.connect(settings.server);
				trace("Connection should have succeeded..");
			} catch (error:Error) {
				trace("Connection failed, please open webserver or change the settings!");
			}
		}
	
		private function init(normalGame:Boolean):void
		{
			gameIsRunning = true;
			
			presentContainer = new MovieClip();
			addChild(presentContainer);
			
			catcher = new Catcher();
			catcher.y = stage.stageHeight-catcher.height;
			thrower = new SaintNicolas();
			thrower.y = thrower.height/2;
			
			infoTable = new InfoTable;
			infoTable.y = infoTable.height*2;
			infoTable.x = infoTable.width*0.7;
			//make unselectable
			infoTable.score.selectable = false
			infoTable.level.selectable = false
			infoTable.lifes.selectable = false
			infoTable.left.selectable = false
			
			addChild(catcher);
			addChild(thrower);
			addChild(infoTable);
			//this switches between Game Introduction and real game.. not entering the frame & not changing level
			if (normalGame) {
				catcher.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
				SwitchLevel();
			}
			//Show the correct info after the level was set
			UpdateInfo();
		}
		
		private function SwitchLevel():void {
		
			//Switch level and settings
			switch (level) {
				case 1:
					time = 1300;
					lifes= 5;
					toCatch =15;
					break;
				case 2:
				time = 1000;
				lifes= 5;
				toCatch =20;
					break;
				case 3:
				time = 800;
				lifes= 5;
					toCatch =25;
					break;
				case 4:
				time = 650;
				lifes= 5;
				toCatch =30;
					break;
				case 5:
				time = 600;
				lifes= 3;
				toCatch=21;
				break;
			}

			tmr = new Timer(time,0);
			tmr.addEventListener(TimerEvent.TIMER,timerHandler);
			tmr.start();
		}
		
		private function nextLevel(event:Event):void {
			level +=1;
			levelFinished.visible = false;
			init(true); 
		}
		
		private function gameEnded(event:Event):void {
			gameFinished.visible = false;
			showScoreInsert()
		}
		private function showHighscores():void {
			
			//make the result responder
			var resultResponder:Responder = new Responder(resultHandler,faultHandler);
			//get scores from database
			conn.call("hiScore.getHiScores",resultResponder);
		
		}
		private function resultHandler(object:Object):void {
			trace("success in getting scores:)");
			var resultaat:Array = object.serverInfo.initialData;
			//Rewrite the data
			showHighscore.nameList.text = "Username\n"
			showHighscore.scoreList.text = "Score\n"
		
			for each(var item:Array in resultaat) {		
			
				var temp:Player = new Player(item[0], item[1], item[2]);
				playerArray.push(temp);
				showHighscore.nameList.appendText(temp.name  + "\n")
				showHighscore.scoreList.appendText(temp.score  + "\n")
			}
			showHighscore.visible = true
		}
		private function faultHandler(event:Object):void {
			trace("An Error Occured " + event );
		}
		private function enterFrameHandler(event:Event):void
		{
			catcher.x = stage.mouseX-catcher.width/2;
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			var rndPosX:int
			oldPosX = thrower.x;
					
			rndPosX = Math.random()*(stage.stageWidth - thrower.width/2);
			//detection if it's in the same place
			while(int(Math.sqrt(oldPosX+25)) == int(Math.sqrt(rndPosX)) || int(Math.sqrt(oldPosX-25)) == int(Math.sqrt(rndPosX))) {
				trace("Detected in almost the same place.. changing location")
				rndPosX = Math.random()*(stage.stageWidth - thrower.width/2);
			}
			//Tween
			TweenLite.to(thrower,(time-50)/1000,{x:rndPosX, onComplete:dropPresent});
		}
		
		private function timerHandler2(event:TimerEvent):void
		{
			var rndPosX:int = Math.random()*(stage.stageWidth - thrower.width/2);
			//Tween
			TweenLite.to(thrower,(time-50)/1000,{x:rndPosX, onComplete:dropPresent});
			if (toCatch == 10) {
				setTimeout(function () {
					showTextBox("Move your mouse to catch presents with the bucket!");
				},time);
			}
			if (toCatch == 8) {
				catcher.x = rndPosX  - 33
				setTimeout(function () {
					showTextBox("\n<= Oops, missed.. one life was substracted!");
				},time);
			} else {
				setTimeout(function () {
					catcher.x = rndPosX + thrower.width /2;
				},time);
			}
			if (toCatch == 6) {	showTextBox("There are 5 different types of presents,\n each one gives you another score."); }
			if (toCatch == 4) {	showTextBox("Click anywhere to go back to the menu:)\n\n\n\t\tGame created by \n\t\tClinciu Andrei George"); }
		}
		
		private function UpdateInfo():void {
			//stupid corelation error.. +"" to fix it
			infoTable.score.text  = highscore +"";
			infoTable.level.text  = level+"";
			infoTable.lifes.text = lifes+"";
			infoTable.left.text = toCatch+""
		}
		private function dropPresent():void
		{
			//Get a random present out of the presents array
			var present:Present;
			var randNr:int = rand(1,13)
			//Goldbag gives a too big score.. only once every 12 presents..
			if (randNr == 7) {
				present =new Present("Gold Pot",new GoldBag,250);
			} else {
				randNr = rand(1,5)
				switch (randNr) {
					case 1:
						present =new Present("Gold Coin",new GoldPiece,10);	
						break;
					case 2:
						present = new Present("Red Gift",new GiftRed,20);	
						break;
					case 3:
						present =new Present("Blue Gift",new GiftBlue,30);
						break;
					case 4:
						present =new Present("Green Gift",new GiftGreen,40);	
						break;
				}
			}			
			present.type.x = thrower.x + thrower.width /2;
			present.type.scaleX= 0.5;
			present.type.scaleY = 0.5;
			present.type.y = thrower.y/2;
			presentContainer.addChild(present.type);
			TweenLite.to(present.type,1,{y:stage.stageHeight+present.type.height,ease:Regular.easeIn,onUpdate:checkHit,onComplete:removePresent,onUpdateParams:[present],onCompleteParams:[present]});
			
		}
		private function removePresent(present:Present):void
		{
		//	var alreadyCleared:Boolean = false;
			if (gameIsRunning) {
				lifes -= 1;
				toCatch -=1;
				UpdateInfo();
				trace("still " + lifes);
				if (lifes <= 0)	{
					//gameover
					cleanStage();
					showScoreInsert();
				} 
				if ((toCatch <= 0 && lifes > 0)) {	
					cleanStage();
			
					if (level >= 5) {
						gameFinished.visible = true	
					} else {
						levelFinished.visible = true;
					}
				}
			}
		}
		
		private function checkHit(present:Present):void
		{
			if(present.type.hitTestObject(catcher) && gameIsRunning)
			{
				//score verhogen
				highscore += present.score
				toCatch -=1;
				
				UpdateInfo();
				
				if (toCatch <= 0) {
					cleanStage();	
					if (level >= 5) {
						gameFinished.visible = true	
					} else {
						levelFinished.visible = true;
					}
				} else {
					try {
						TweenLite.killTweensOf(present.type);
						presentContainer.removeChild(present.type);
					} catch (e:Error) {
						trace("Error occured when trying to remove tweens  in checkhit.. " + e.message  + "\n"  + e.name + " id " + e.errorID)
					}
				}
			} else	{
				//score verlagen
			}
		}
		
		private function cleanStage():void
		{
			gameIsRunning = false
			tmr.stop();
			TweenLite.killTweensOf(thrower);
			
			for each(var present:Present in presentContainer) {
				TweenLite.killTweensOf(present.type)
				presentContainer.removeChild(present.type);
			}
			try {
				removeChild(presentContainer);
				removeChild(catcher);
				removeChild(thrower);
				removeChild(infoTable);
			} catch (e:Error) {
				trace("Error occured on clean stage.. " + e.toString())
			}
			
		}
	
		private function showScoreInsert():void {
			var form:Form = new Form()
			form.x = (stage.stageWidth - form.width)/2 ;
			form.y = (stage.stageHeight - form.height)/2;
			form.headText.selectable  = false
			form.submit.selectable  = false
			form.submit.addEventListener(MouseEvent.CLICK,sendListener);
			form.submit.buttonMode = true
			form.username.addEventListener(KeyboardEvent.KEY_DOWN,function (event:KeyboardEvent) {
				if (event.keyCode == 13) {	sendListener(event) }
			});
			form.username.addEventListener(MouseEvent.CLICK,formRemoveText);
			addChild(form)
		}
		private function formRemoveText(event:Event):void {
			event.currentTarget.text = "" 
			event.currentTarget.removeEventListener(MouseEvent.CLICK,formRemoveText);
		}
		
		private function sendListener(event:Event):void {
			var insertResponder:Responder = new Responder(insertResultHandler,faultHandler);
			var data:Object = new Object();
			data.name = event.currentTarget.parent.username.text;
			data.score = highscore;
			
			conn.call("hiScore.insertScore",insertResponder,data);
			removeChild(event.currentTarget.parent)
		}
		
		private function insertResultHandler(result:Object):void {
			if(result) {
				trace("yeeepiee inserted")
				//Show Highscores!
				showHighscores();
			}else {
				trace("not inserted:(")
			}
		}
		
		//menu Functions
		private function showMenu(event:Event):void {
			menu.visible = true
			showHighscore.visible = false
		}
		private function menuClick(event:Event):void {
			var target:String = 	event.currentTarget.name
			trace(target)
			if (target == "highscores") {
				//Show highscores
				menu.visible = false
				showHighscores()
				
			}else if  (target == "newGame"){
				menu.visible = false
				level = 1;
				init(true);
			} else if  (target == "instructions"){
				//Give instructions
				menu.visible = false
				showInstructions();
			}
		}
		private function showInstructions():void {
			instructions.visible = true
			titleField.x = stage.stageWidth*0.25
			titleField.y = stage.stageHeight*0.4
			showTextBox("Saint Nicolas is throwing presents for all the children. \nHelp him by catching all the presents." +
				" \n Don't miss too many or you will lose the game!\n Press P in the game to pause it.")
			
			init(false);
			isInstructing = true; // so we don't allow to pause
			//simple settings
			time = 1300;
			lifes= 3;
			toCatch=10;
			//update the info
			UpdateInfo()
			//setup timer
			tmr = new Timer(time,8);
			tmr.addEventListener(TimerEvent.TIMER,timerHandler2);
			// Click to go back..
			instructions.addEventListener(MouseEvent.CLICK,instructionClickHandler);
			
			//start timer!
			setTimeout( function () {		tmr.start();	}, 3500)
		
		}
		private function instructionClickHandler(event:Event):void {
				cleanStage(); 
				instructions.visible = false
				menu.visible = true
				isInstructing = false
		}
		private function showTextBox(text:String):void {
			titleField.text = text;
		}
		private function rand(min:int, max:int):int {
			return min + (max - min) * Math.random();
		}
		//music toggle function
		public function ToggleMusic(e:Event):void
		{
			if (!isPlaying) {
				sc = music.play();
				isPlaying = true;
			} else {
				//online tutorials say it's best to verify if it exists... dunno why
				if(sc != null)		{		sc.stop();				}
				isPlaying = false;
			}
		}
	}
}
