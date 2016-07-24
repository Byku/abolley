package
{
	import com.bit101.components.*;
	import flash.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.Timer;
	import nape.geom.*;
	import nape.util.*;
	import Tests.*;
	import flash.system.Security;

	[SWF(width="640", height="480", backgroundColor="#000000", frameRate="30")]
	public class Main extends Sprite
	{
		public static const FPS:Number = 60;
		public static const stageWidth:Number = 640;
		public static const stageHeight:Number = 480;
		
		private var isKeyPressed:Array = new Array();
		
		private static var tests:Vector.<Class> = new <Class>[ Volley];
		
		private var currentTest:int = 0;
		private var test:Test = null;
		
		
		private var ballForMenu:Bitmap;
		
		private var onePlayerButtonSprite:Sprite;
		private var twoPlayerButtonSprite:Sprite;
		private var creditsButtonSprite:Sprite;
		private var howToPlayButtonSprite:Sprite;
		private var backButtonSprite:Sprite;
		
		private var creditsBackgroundSptite:Sprite;
		private var creditsBackground:Bitmap;
		private var howtoPlayBackgroundSprite:Sprite;
		private var howtoPlayBackground:Bitmap;
		
		//задержка перед отображением меню после конца партии
		private var timer4EndOfGame:Timer;
		
		private var onePlayer:Boolean;
		
		private var testNameLabel:Label;
		private var testUI:VBox;
		
		private var debugParent:Sprite = new Sprite();
		private var debug:Debug = new ShapeDebug(stageWidth, stageHeight);
		public var keyArray:Array = new Array();
		
		private var menuSprite:Sprite = new Sprite();

		
		public function Main():void
		{
			Security.allowDomain("dendy-store.ru");
			new Boot();
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function showMenu():void {
			addChild(menuSprite);
			startAllListener();
		}
		
		public function showBackButton():void {
			addChild(backButtonSprite);
			backButtonSprite.addEventListener(MouseEvent.CLICK, backButtonSpriteClickListener);
			backButtonSprite.addEventListener(MouseEvent.MOUSE_OVER, backButtonSpriteOverListener);
		}
		
		private function backButtonSpriteOverListener(e:MouseEvent):void 
		{
			ballForMenu.y = 290;
			ballForMenu.x = 15;
		}
		
		private function backButtonSpriteClickListener(e:MouseEvent):void 
		{
			backButtonSprite.removeEventListener(MouseEvent.CLICK, backButtonSpriteClickListener);
			backButtonSprite.removeEventListener(MouseEvent.MOUSE_OVER, backButtonSpriteOverListener);
			removeChild(backButtonSprite);
			hideMenu();
		}
		
		public function hideMenu():void {
			removeChild(menuSprite);
			stopAllListener();
			for (var i:Number = 0; i < numChildren; i++) {
				if ( getChildAt(i) === backButtonSprite) {
					removeChild(backButtonSprite);
				}
			}
		}
		
		private function startKeyboardListeners():void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpRightListener);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpLeftListener);
		}
		
		private function stopKeyboardListeners():void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpRightListener);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpLeftListener);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		//	debugParent.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		//	stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		//	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			//stage.frameRate = FPS;
			stage.frameRate = 60;
			
			debugParent.graphics.beginFill(0xC0C0C0, 1);
			debugParent.graphics.drawRect(0, 0, stageWidth, stageHeight);
			debugParent.graphics.endFill();
			//debugParent.addChild(debug.display); //////// здесь отображение скелетов			////////////////////////////////////		
			addChild(debugParent);
			debug.drawConstraints = false;
	
			
			createUI();
			
			

			var startBackgroundBitmap:BitmapData = (new GFX.StartBackgroundSprite()).bitmapData;
			var bitmap1:Bitmap = new Bitmap(startBackgroundBitmap);
			bitmap1.y = 0;
			bitmap1.alpha = 1; //0.3 для тестов
			menuSprite.addChild(bitmap1);		
			
			var ballForMenuBitmap:BitmapData = (new GFX.BallForMenuSprite()).bitmapData;
			ballForMenu = new Bitmap(ballForMenuBitmap);
			ballForMenu.y = -50;
			ballForMenu.x = -50;
			ballForMenu.alpha = 1;
			menuSprite.addChild(ballForMenu);
			
			var spaceBitmap:BitmapData = (new GFX.SpaceSprite()).bitmapData;
			
			var spaceOP:Bitmap = new Bitmap(spaceBitmap);
			spaceOP.width = 170;
			spaceOP.height = 30;
			onePlayerButtonSprite = new Sprite();
			onePlayerButtonSprite.addChild(spaceOP);
			onePlayerButtonSprite.x = 30;
			onePlayerButtonSprite.y = 150;
			menuSprite.addChild(onePlayerButtonSprite);
			
			
			var spaceTP:Bitmap = new Bitmap(spaceBitmap);
			spaceTP.width = 170;
			spaceTP.height = 30;
			twoPlayerButtonSprite = new Sprite();
			twoPlayerButtonSprite.addChild(spaceTP);
			twoPlayerButtonSprite.x = 30;
			twoPlayerButtonSprite.y = 190;
			menuSprite.addChild(twoPlayerButtonSprite);
			
			
			var spaceC:Bitmap = new Bitmap(spaceBitmap);
			spaceC.width = 170;
			spaceC.height = 30;
			creditsButtonSprite = new Sprite();
			creditsButtonSprite.addChild(spaceC);
			creditsButtonSprite.x = 30;
			creditsButtonSprite.y = 220;
			menuSprite.addChild(creditsButtonSprite);
			
			var spaceHTP:Bitmap = new Bitmap(spaceBitmap);
			spaceHTP.width = 170;
			spaceHTP.height = 30;
			howToPlayButtonSprite= new Sprite();
			howToPlayButtonSprite.addChild(spaceHTP);
			howToPlayButtonSprite.x = 30;
			howToPlayButtonSprite.y = 250;
			menuSprite.addChild(howToPlayButtonSprite);
			
			//var backButtonBitmap = (new GFX.BackButtonSprite()).Bi
			backButtonSprite = new Sprite();
			backButtonSprite.addChild(new Bitmap((new GFX.BackButtonSprite()).bitmapData));
			backButtonSprite.x = 31;
			backButtonSprite.y = 295;
			

		
			var creditsBackgroundBitmap:BitmapData = (new GFX.CreditsBackgroundSprite()).bitmapData;
			creditsBackground = new Bitmap(creditsBackgroundBitmap);
			creditsBackgroundSptite = new Sprite();
			creditsBackgroundSptite.addChild(creditsBackground);
			
			var howtoPlayBitmap:BitmapData = (new GFX.HowToPlaySprite()).bitmapData;
			howtoPlayBackground = new Bitmap(howtoPlayBitmap);
			howtoPlayBackgroundSprite = new Sprite();
			howtoPlayBackgroundSprite.addChild(howtoPlayBackground);
			
			showMenu();		
			
			
			
			/*
			//кнопка стартГейм
		
			startButtonSprite = new Sprite();
			var startButtonBitmap:BitmapData = (new GFX.ButtonStartGameSprite()).bitmapData;
			bitmapStartButton = new Bitmap(startButtonBitmap);
			bitmapStartButton.y = 0;
			bitmapStartButton.alpha = 1; //0.3 для тестов
			startButtonSprite.addChild(bitmapStartButton);
			menuSprite.addChild(startButtonSprite);
			bitmapStartButton.x = 220;
			bitmapStartButton.y = 215;
			startButtonSprite.addEventListener(MouseEvent.CLICK, bitmapStartButtonClickListener);
			
			//кнопка One Player
			onePlayerButtonSprite = new Sprite();
			menuSprite.addChild(createButton(onePlayerButtonSprite, bitmapOnePlayerButton, new GFX.ButtonOnePlayerSprite().bitmapData));
			onePlayerButtonSprite.addEventListener(MouseEvent.CLICK, onePlayerButtonClickListener);
			
			twoPlayerButtonSprite = new Sprite();
			menuSprite.addChild(createButton(twoPlayerButtonSprite, bitmapTwoPlayerButton, new GFX.ButtonTwoPlayerSprite().bitmapData));
			twoPlayerButtonSprite.addEventListener(MouseEvent.CLICK, twoPlayerButtonClickListener);

			creditsButtonSprite = new Sprite();
			menuSprite.addChild(createButton(creditsButtonSprite, bitmapCreditsButton, new GFX.ButtonCreditsSprite().bitmapData));
			creditsButtonSprite.addEventListener(MouseEvent.CLICK, creditsButtonClickListener);

			//добавить бол4меню и сделат так чтобы она выделяла выделенное меню.
			//нарисовать меню. особенно кнопку Хау ту плей.
			*/
			setTest(0);
			test.newRally(150);
			//test.addEventListener(Test.GAME_OVER, gameOverListener);

		}
		
		private function gameOverListener(e:Event):void {
			test.removeEventListener(Test.GAME_OVER, gameOverListener);
			stopKeyboardListeners();
			//TODO: добавить сначала показ баннеров, а потом уже меню
			
			if (test.getLeftScore() > test.getRightScore()) {
				trace("победил левый, отобразить баннер1");
			} else {
				trace("победил правый, отобразить баннер2");
			}
			timer4EndOfGame = new Timer(4000, 1);
			timer4EndOfGame.addEventListener(TimerEvent.TIMER, timer4EndOfGameListener);
			timer4EndOfGame.start();
		}
		
		private function timer4EndOfGameListener(e:TimerEvent):void 
		{
			showMenu();
			test.endOfGame();
		}
		
		public function startAllListener():void {
			onePlayerButtonSprite.addEventListener(MouseEvent.CLICK, onePlayerButtonClickListener);
			onePlayerButtonSprite.addEventListener(MouseEvent.MOUSE_OVER, onePlayerButtonMouseOverListener);
			twoPlayerButtonSprite.addEventListener(MouseEvent.CLICK, twoPlayerButtonClickListener);
			twoPlayerButtonSprite.addEventListener(MouseEvent.MOUSE_OVER, twoPlayerButtonMouseOverListener);
			creditsButtonSprite.addEventListener(MouseEvent.CLICK, creditsButtonClickListener);
			creditsButtonSprite.addEventListener(MouseEvent.MOUSE_OVER, creditsButtonMouseOverListener);
			howToPlayButtonSprite.addEventListener(MouseEvent.CLICK, howToPlayButtonClickListener);
			howToPlayButtonSprite.addEventListener(MouseEvent.MOUSE_OVER, howToPlayButtonMouseOverListener);
		}
		
		private function stopAllListener():void {
			twoPlayerButtonSprite.removeEventListener(MouseEvent.CLICK, twoPlayerButtonClickListener);
			twoPlayerButtonSprite.removeEventListener(MouseEvent.MOUSE_OVER, twoPlayerButtonMouseOverListener);
			
			onePlayerButtonSprite.removeEventListener(MouseEvent.CLICK, onePlayerButtonClickListener);
			onePlayerButtonSprite.removeEventListener(MouseEvent.MOUSE_OVER, onePlayerButtonMouseOverListener);
			
			creditsButtonSprite.removeEventListener(MouseEvent.CLICK, creditsButtonClickListener);
			creditsButtonSprite.removeEventListener(MouseEvent.MOUSE_OVER, creditsButtonMouseOverListener);
			
			howToPlayButtonSprite.removeEventListener(MouseEvent.MOUSE_OVER, howToPlayButtonMouseOverListener);
			howToPlayButtonSprite.removeEventListener(MouseEvent.CLICK, howToPlayButtonClickListener);
		}
		
		private function howToPlayButtonMouseOverListener(e:MouseEvent):void {
			ballForMenu.y = 257;
			ballForMenu.x = 15;
		}
		
		private function creditsButtonMouseOverListener(e:MouseEvent):void 	{
			ballForMenu.x = 15;
			ballForMenu.y = 220;
		}
		
		private function twoPlayerButtonMouseOverListener(e:MouseEvent):void {
			ballForMenu.y = 187;
			ballForMenu.x = 15;
		}
		
		private function onePlayerButtonMouseOverListener(e:MouseEvent):void {
			ballForMenu.y = 152;
			ballForMenu.x = 15;
		}
		
		
		private function howToPlayButtonClickListener(e:MouseEvent):void {
			trace("сработала кнопка How To Play");
			addChild(howtoPlayBackgroundSprite);
			addChild(backButtonSprite);
			backButtonSprite.addEventListener(MouseEvent.CLICK, closeHowtoPlayListener);
			howtoPlayBackgroundSprite.addEventListener(MouseEvent.CLICK, closeHowtoPlayListener);
			stopAllListener();
		}
		
		private function closeHowtoPlayListener(e:MouseEvent):void 
		{
			backButtonSprite.removeEventListener(MouseEvent.CLICK, closeHowtoPlayListener);
			removeChild(backButtonSprite);
			howtoPlayBackgroundSprite.removeEventListener(MouseEvent.CLICK, closeHowtoPlayListener);
			removeChild(howtoPlayBackgroundSprite);
			startAllListener();
		}
		
		private function creditsButtonClickListener(e:MouseEvent):void {
			trace("сработала кнопка Кредитс");
			addChild(creditsBackgroundSptite);
			addChild(backButtonSprite);
			backButtonSprite.addEventListener(MouseEvent.CLICK, closeCreditsListener);
			creditsBackgroundSptite.addEventListener(MouseEvent.CLICK, closeCreditsListener);
			stopAllListener();
		}
		
		private function closeCreditsListener(e:MouseEvent):void 
		{
			creditsBackgroundSptite.removeEventListener(MouseEvent.CLICK, closeCreditsListener);
			backButtonSprite.removeEventListener(MouseEvent.CLICK, closeCreditsListener);
			removeChild(creditsBackgroundSptite);
			removeChild(backButtonSprite);
			startAllListener();
		}
		
		private function twoPlayerButtonClickListener(e:MouseEvent):void {
			trace("сработала кнопка Two Плейерs");
			hideMenu();
			startKeyboardListeners();
			test.addEventListener(Test.GAME_OVER, gameOverListener);
			test.newSet();
			onePlayer = false;
		}
		
		private function onePlayerButtonClickListener(e:MouseEvent):void {
			trace("сработала кнопка Уан Плейер");
			hideMenu();
			startKeyboardListeners();
			test.addEventListener(Test.GAME_OVER, gameOverListener);
			test.newSet();
			test.startAI();
			onePlayer = true;
			
		}

		
/*
		private function mouseDown(e:MouseEvent):void
		{
			test.mouseDown(new Vec2(e.stageX, e.stageY));
		}
		
		private function mouseMove(e:MouseEvent):void
		{
			//test.mouseMove(new Vec2(e.stageX, e.stageY), e.buttonDown);
		}
		
		private function mouseUp(e:MouseEvent = null):void
		{
			test.mouseUp(new Vec2(e.stageX, e.stageY));
		}
		*/
		private function keyDownListener(e:KeyboardEvent):void {
			isKeyPressed[e.keyCode] = e.keyCode;
			//trace(e.keyCode);
		}
		
		private function keyUpRightListener(e:KeyboardEvent):void{
			isKeyPressed[e.keyCode] = 0;

			if (e.keyCode == 87){
				test.heroJumpA();
			}
			//если отпускаем кнопку удара, то запускаем функцию isNotAttacken

			if (e.keyCode == 96 || e.keyCode == 32) {
				test.isRightPlayerNotAttacked();
			}
		}
		
		private function keyUpLeftListener(e:KeyboardEvent):void{
			isKeyPressed[e.keyCode] = 0;
			if (e.keyCode == 38){
				test.heroJump();
			}

			//если отпускаем кнопку удара, то запускаем функцию isNotAttacken
			if (e.keyCode == 86 || e.keyCode == 192) {
				test.isLeftPlayerNotAttacked();
			}
		}
		
		private function enterFrame(e:Event):void {
			test.space.step(1.0 / FPS);
			test.update();
			//атака левым игроком
			if (isKeyPressed[86] == 86 || isKeyPressed[192] == 192) {
					test.attack();
			}
			
			//атака правым игроком
			if (isKeyPressed[96] == 96 || isKeyPressed[32] == 32) {
				test.attackR();
			}
			//остановка героев, чтобы не скользили как по льду
			test.antiheroStop();
			test.heroStop();
			//передвижение героев
			
			if (onePlayer) {
				test.onePlayerMove();
				test.onePlayerAttack();
				if (Math.random() > 0.97) {
					test.onePlayerJump();
				}
			}
			
			
			//если переменная=1, то оставить так, а если =0, то запустить функцию, которая расчитывает движение левого игрока.
			//а для правого оставить так.
			for (var i:int = 0; i < isKeyPressed.length; ++i) {
				if (isKeyPressed[i] == 37 || isKeyPressed[i] == 39 || isKeyPressed[i] == 65 || isKeyPressed[i] == 68){
					test.heroMove(isKeyPressed[i]);
				}
			}
			//наращивание силы прыжка героям
			if (isKeyPressed[38] == 38){
				test.addJumpPower(isKeyPressed[38]);
			}
			if (isKeyPressed[87] == 87){
				test.addJumpPower(isKeyPressed[87]);
			}
			
			//приседание
			if (isKeyPressed[40] == 40) {
				test.rightPlayerSeat();
			}
			if (isKeyPressed[83] == 83) {
				test.leftPlayerSeat();
			}
		
			debug.clear();
			debug.draw(test.space);
		}
		
		private function setTest(n:int):void
		{
			
			while (testUI.numChildren > 0)
				testUI.removeChildAt(0);
			if (test)
				removeChild(test.overlaySprite);
			
			currentTest = n;
			test = new tests[currentTest];
			//testNameLabel.text = test.name;
			test.createUI(testUI);
			addChildAt(test.overlaySprite, getChildIndex.length);
			test.overlaySprite.mouseEnabled = false;
			
		}
		
		private function createUI():void
		{
			new FPSMeter(this, stageWidth - 40,0,"фпс");
			
			var vbox:VBox = new VBox(this);
			var hbox:HBox = new HBox(vbox);
			
			testNameLabel = new Label(this);
			testNameLabel.x = (stageWidth - testNameLabel.width) / 2;
			
			var b:PushButton;
			b = new PushButton(hbox, 0, 0, "menu", function(e:Event):void
				{
					//test.newSet();
					showMenu();
					showBackButton();
				});
			b.width = 60;
			/*b = new PushButton(hbox, 0, 0, "prev", function(e:Event):void
				{
					setTest((tests.length + currentTest - 1) % tests.length);
				});
			b.width = 40
			b = new PushButton(hbox, 0, 0, "reset", function(e:Event):void
				{
					setTest(currentTest);
				});
			b.width = 40;
			*/	
			testUI = new VBox(vbox);
			
		}
	
	}
}