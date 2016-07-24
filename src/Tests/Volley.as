package Tests 
{
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import nape.callbacks.BodyListener;
	import nape.dynamics.InteractionFilter;
	import flash.net.*;

	import nape.callbacks.CbType;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.phys.BodyType;
	import nape.geom.*;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.constraint.DistanceJoint;
	import nape.dynamics.Arbiter;
	import nape.callbacks.CbEvent;
	
	
	public class Volley extends Test 
	{
		private var body:Body;
		private var bodyH:Body;
		private var bodyA:Body;
		private var bodyLeftPlayer:Body;
		private var bodyRightPlayer:Body;
		private var bodyMenuPlayer:Body;
		private var bodyAura:Body;
		private var bodyKinematicFloor:Body;
		
		public static const SIT_ATTACK:String = "sitHit";
		
		private var bodyRadius:int = 30;
		private var ballFinder:MovieClip;
		
		private var timer4goal:Timer;
		private var netArray:Array;
		public var heroType:CbType;
		private var distJoint:DistanceJoint;
		
		//фильтры столкновений
		private var filterAura:InteractionFilter = new InteractionFilter(0x001, ~0x001, 0x100, 0x100);
		private var filterBall:InteractionFilter = new InteractionFilter(0x001, 0x001, 0x100, 0x100);
		private var filterFloor:InteractionFilter = new InteractionFilter(0x001, ~0x001, 0x100, 0x100);
		private var filterHero:InteractionFilter = new InteractionFilter(0x001, 0x001, 0x100, 0x100);
		private var filterBallAura:InteractionFilter = new InteractionFilter(0x000, 0x000, 0x100, 0x100);
		private var filterMenuHero:InteractionFilter = new InteractionFilter(0x100, 0x100, 0x100, 0x100);
	//	private var firstSensorGroup:int = 0x00000001;
	
		public var LPlayerOnFloor:Boolean;
		private var RPlayerOnFloor:Boolean;
		
		private var leftTouchCounter:int;
		private var rightTouchCounter:int;
		
		private var prevRPlayerYVelocity:Number;
		private var prevLPlayerYVelocity:Number;
		
		private var isRightPlayerAttacked:Boolean;
		private var isLeftPlayerAttacked:Boolean;
		

		private var jumpOnePlayerDelayTimer:Timer;
		private var stopTrippleRoboAttackTimer:Timer;
		
		//Загрузчик земли
		private var groundLoader:Loader;
		
		//домен
		private var domenName:String = "http://abvolley.ru/swf/";
		
		//картинка героя
		private var bitmapHR:Bitmap;
		private var bitmapHL:Bitmap;
		//картинка мяча
		private var bitmapBall:Sprite;
		
		//ограничитель частых касаний. если равно 0, то можно засчтывать касание игроком мяча
		private var limiterOftenTouch:int = 0;
		private const limitOT:int = 11;
		
		private var isBallInLeftAura:Boolean;
		private var wasBallInLeftAura:Boolean;
		private var isBallInRightAura:Boolean;
		private var wasBallInRightAura:Boolean;
		
		private var bitmap:Bitmap;
		private var bitmap_:Bitmap;
		//private var body:Body;
		private var bitmapPt:Vec2;
		private var bitmapPt_:Vec2;
		private var bitmapBallPt:Vec2;
		
		//загрузим тело героев
		private var brpM:MovieClip;
		private var ldrBRP:Loader;
		private var blpM:MovieClip;
		private var ldrBLP:Loader;
		private var bmpM:MovieClip;
		private var ldrBMP:Loader;
		
		//загрузим мяч
//		private var ballM:MovieClip;
//		private var ldrBall:Loader;
		
		private var isRightPlayerSeat:Boolean = false;
		private var isLeftPlayerSeat:Boolean = false;
		
		//загрузим табло (все 4 цифры по отдельности)
		//TODO: нужно ещё сделать отдельную swf-ку на двоеточие в середине табла и точечки для обозначения выигранных партий
		private var ldrTabloDigitLeftTen:Loader;
		private var tabloDigitLeftTenM:MovieClip;
		private var ldrTabloDigitLeftOne:Loader;
		private var tabloDigitLeftOneM:MovieClip;
		private var ldrTabloDigitRightTen:Loader;
		private var tabloDigitRightTenM:MovieClip;
		private var ldrTabloDigitRightOne:Loader;
		private var tabloDigitRightOneM:MovieClip;
		
		public function Volley() 
		{
			super("Volley");
			createWalls(Material.steel());
			createGround();
			heroType = new CbType();
			heroType.userData = "blabla";
			LPlayerOnFloor = false;
			RPlayerOnFloor = false;
			isLeftPlayerAttacked = false;
			isRightPlayerAttacked = false;

			ballFinder = new BallFinder();
			overlaySprite.addChild(ballFinder);
//////////////////////////////////////////////////////создаем тестовую ауру//////////////////
//			bodyAura = new Body(BodyType.KINEMATIC, new Vec2(200, 200));
//			bodyAura.shapes.add(new Circle(50, new Vec2(0, 0), Material.glass(), filter1));
//			bodyAura.space = space;
//////////////////////////////////////////////////////кончили создавать ауру/////////////////

//////////////////////////////////////////////////////создаем слой, который определит касание пола мячом//////////////
			bodyKinematicFloor = new Body(BodyType.KINEMATIC, new Vec2(0, 379));
			bodyKinematicFloor.shapes.add(new Polygon(Polygon.rect(0, 0, 640, 1), Material.steel(), filterFloor));
			var cbType : CbType = new CbType();
			cbType.userData = "floor";
			bodyKinematicFloor.cbType = cbType;
			bodyKinematicFloor.space = space;

//////////////////////////////////////////////////////кончили создавать слой, который определит касание пола мячом//////////////
//////////////////////////////////////////////////////////создаем мяч////////////////////////			
			body = new Body(BodyType.DYNAMIC, new Vec2(400, 300));
			body.shapes.add(new Circle(bodyRadius, new Vec2(0, 0), Material.wood(), filterBall));
			//body.shapes.add(new Circle(30, new Vec2(60, 0), Material.wood(), filterBall));
			heroType.userData = "ball";
			body.cbType = heroType;
			bitmapBallPt = body.localToWorld(new Vec2());
			body.graphic = bitmapBall;
			body.align();
			//body.allowRotation = true;
			bitmapBallPt = body.worldToLocal(bitmapBallPt);
			
			body.space = space;
/////////////////////////////////////////////////////кончили создавать мяч////////////////////

/////////////////////////////////////////////////////создаем левого игрока////////////////////
			bodyLeftPlayer = new Body(BodyType.DYNAMIC, new Vec2(40, 150));
			bodyLeftPlayer.shapes.add(new Circle(25, new Vec2(0, 0), Material.steel(), filterHero));
			//bodyLeftPlayer.shapes.add(new Circle(26, new Vec2(25, 5), Material.steel(), filterAura));
			bodyLeftPlayer.shapes.add(new Circle(75, new Vec2(0, 0), Material.steel(), filterAura));
			heroType = new CbType();
			bitmapPt_ = bodyLeftPlayer.localToWorld(new Vec2());
			heroType.userData = "leftPlayer";
			bodyLeftPlayer.cbType = heroType;
			bodyLeftPlayer.allowRotation = false;
			bodyLeftPlayer.align();
			bitmapPt_ = bodyLeftPlayer.worldToLocal(bitmapPt_);
			bodyLeftPlayer.space = space;
/////////////////////////////////////////////////////кончили создавать левого игрока//////////
//////////////////////load and attach skin to left Player/////////////////////////////////////
//			var blpRequest:URLRequest = new URLRequest(domenName + "aebaL.swf");
//			ldrBLP = new Loader();
//			// todo change
//			ldrBLP.contentLoaderInfo.addEventListener(Event.COMPLETE, blpLoaderComplete);
//			ldrBLP.load(blpRequest);

			blpM = new  player_left();
			overlaySprite.addChild(blpM);
//////////////////////end of load and attach skin to left Player//////////////////////////////
/////////////////////////////////////////////////////создаем правого игрока///////////////////
			bodyRightPlayer = new Body(BodyType.DYNAMIC, new Vec2(450, 150));
			//bodyRightPlayer.shapes.add(new Polygon(Polygon.rect(0, 0, 50, 70), Material.steel(), filterHero));
			bodyRightPlayer.shapes.add(new Circle(25, new Vec2(0, 0), Material.steel(), filterHero));
			bodyRightPlayer.shapes.add(new Circle(75, new Vec2(0, 0), Material.steel(), filterAura));
			heroType = new CbType();
			bitmapPt = bodyRightPlayer.localToWorld(new Vec2());
			heroType.userData = "rightPlayer";
			bodyRightPlayer.cbType = heroType;
			bodyRightPlayer.allowRotation = false;
			
			bodyRightPlayer.align();
			bitmapPt = bodyRightPlayer.worldToLocal(bitmapPt);
			bodyRightPlayer.space = space;
/////////////////////////////////////////////////////кончили создавать правого игрока//////////
/////////////////////////////загружаем и прикрепляем внешность правого игрока//////////////////
//			var brpRequest:URLRequest = new URLRequest(domenName + "aebaR.swf");
//			ldrBRP = new Loader();
//			ldrBRP.contentLoaderInfo.addEventListener(Event.COMPLETE, brpLoaderComplete);
//			ldrBRP.load(brpRequest);
			brpM = new  player_right();
			overlaySprite.addChild(brpM);
/////////////////////////////кончили прикреплять внешность правого игрока//////////////////////
		}

		private function blpLoaderComplete(e:Event):void {
			blpM = e.target.content;
			overlaySprite.addChild(blpM);
			blpM.stop();
		}
		
		private function brpLoaderComplete(e:Event):void {
			brpM = e.target.content;
			overlaySprite.addChild(brpM);
			brpM.stop();
		}
		
		public function menuHero():void {
			
/////////////////////////////////////////////////////создаем левого игрока////////////////////
			bodyMenuPlayer = new Body(BodyType.DYNAMIC, new Vec2(400, 150));
			bodyMenuPlayer.shapes.add(new Circle(25, new Vec2(0, 0), Material.steel(), filterMenuHero));
			bodyMenuPlayer.shapes.add(new Circle(75, new Vec2(0, 0), Material.steel(), filterAura));
			heroType = new CbType();
			bitmapPt_ = bodyMenuPlayer.localToWorld(new Vec2());
			heroType.userData = "MenuPlayer";
			bodyMenuPlayer.cbType = heroType;
			bodyMenuPlayer.allowRotation = false;
			bodyMenuPlayer.align();
			bitmapPt_ = bodyMenuPlayer.worldToLocal(bitmapPt_);
			bodyMenuPlayer.space = space;
/////////////////////////////////////////////////////кончили создавать левого игрока//////////
//////////////////////load and attach skin to left Player/////////////////////////////////////
			var bmpRequest:URLRequest = new URLRequest(domenName + "aebaL.swf");
			ldrBMP = new Loader();
			ldrBMP.contentLoaderInfo.addEventListener(Event.COMPLETE, bmpLoaderComplete);
			ldrBMP.load(bmpRequest);
//////////////////////end of load and attach skin to left Player//////////////////////////////
		}
		
		private function bmpLoaderComplete(e:Event):void 
		{
			bmpM = e.target.content;
			overlaySprite.addChild(bmpM);
			bmpM.stop();
		}
		
		public function deleteMenuHero():void {
			bodyMenuPlayer.space = null;
		}
		
		
/*		private function ballLoaderComplete(e:Event):void {
			ldrBall.contentLoaderInfo.removeEventListener(Event.COMPLETE, ballLoaderComplete);
			ballM = e.target.content;
			overlaySprite.addChild(ballM);
			handLM.stop();
		}
		*/
		//касания правого игрока
		private function rightPlayerContacts():void {
			for(var j:int = 0; j<bodyRightPlayer.arbiters.length; j++) {
				var arb:Arbiter = bodyRightPlayer.arbiters.at(j);

				//стоит ли игрок на полу
				if (arb.isSensorArbiter() && (arb.body2 == bodyKinematicFloor||arb.body1 == bodyKinematicFloor))
				{
					//trace("столкновение тела с полом");
					if (RPlayerOnFloor == false){
						RPlayerOnFloor = true;
					}	
				}
			}
		}
		
		//касания левого игрока
		private function leftPlayerContacts():void {
			for(var j:int = 0; j<bodyLeftPlayer.arbiters.length; j++) {
				var arb:Arbiter = bodyLeftPlayer.arbiters.at(j);

				//стоит ли игрок на полу
				if (arb.isSensorArbiter() && (arb.body2 == bodyKinematicFloor||arb.body1 == bodyKinematicFloor))
				{
					//trace("столкновение тела с полом");
					if (LPlayerOnFloor == false)
					{
						LPlayerOnFloor = true;
					}
					
				}
			
			}
		}
		
		//касания мяча
		private function ballContacts():void {
			for(var i:int = 0; i<body.arbiters.length; i++){
				var arb:Arbiter = body.arbiters.at(i);
				if (arb.isSensorArbiter() && (arb.body1 == bodyLeftPlayer||arb.body2 == bodyLeftPlayer )){
					isBallInLeftAura = true;
					//начало касание мяча и ауры левого игрока
					if (wasBallInLeftAura == false){
						wasBallInLeftAura = true; 
					}	
					
					if (body.allowMovement == false) {
						if (!getFlagIsRallyNow()) {
							body.allowMovement = true;
							setFlagIsRallyNow(true);
						}
					}
				}
				
				if (arb.isCollisionArbiter() && (arb.body1 == bodyLeftPlayer || arb.body2 == bodyLeftPlayer )) {
					
					if (getFlagIsRallyNow()) {
						if (limiterOftenTouch == 0) {
							limiterOftenTouch = limitOT;
							leftTouchCounter++;
							rightTouchCounter = 0;
						}
					}
				}
			
				
				if (arb.isCollisionArbiter() && (arb.body1 == bodyRightPlayer || arb.body2 == bodyRightPlayer )) {
					if (getFlagIsRallyNow()) {
						if (limiterOftenTouch == 0) {
							limiterOftenTouch = limitOT;
							rightTouchCounter++;
							leftTouchCounter = 0;
						}
					}
				}
				
				if (arb.isSensorArbiter() && (arb.body1 == bodyRightPlayer || arb.body2 == bodyRightPlayer)) {
					isBallInRightAura = true;
					if (wasBallInRightAura == false) {
						wasBallInRightAura = true;
					}
					if (body.allowMovement == false) {
						if (!getFlagIsRallyNow()) {
							body.allowMovement = true;
							setFlagIsRallyNow(true);
						}
					}
				}
				//если мяч коснулся пола
				if (arb.isSensorArbiter() && (arb.body1 == bodyKinematicFloor||arb.body2 == bodyKinematicFloor )){
					if (getFlagIsRallyNow()) { 
						if (!getStopTrippleCounts()) {
							if(!getStopGoals()){
								goal();
							}
						}
					}
				}		
			}
			if (wasBallInLeftAura == true && isBallInLeftAura == false) {	
				wasBallInLeftAura = false;
				//trace("мяч вылетел из ауры");
			}
			if (wasBallInRightAura == true && isBallInRightAura == false) {
				wasBallInRightAura = false;
			}
			
			if (RPlayerOnFloor == false) {
				//trace("юхууууу");
				
			}
		}
		
		public function setLeftTouchCounter(il:int):void {
			leftTouchCounter = il;
		}
		
		public function setRightTouchCounter(ir:int):void {
			rightTouchCounter = ir;
		}		
		
		override public function update():void
		{
//			trace (bitmapBall.x, bitmapBall.y)
			//trace(leftTouchCounter + " " + rightTouchCounter + " limit: " + limiterOftenTouch);
			//trace(limiterOftenTouch);
			isBallInLeftAura = false;
			isBallInRightAura = false;
			RPlayerOnFloor = false;
			LPlayerOnFloor = false;
			if(limiterOftenTouch>0) limiterOftenTouch--;
			
			rightPlayerContacts();
			leftPlayerContacts();
			ballContacts();
	
//			var pt:Vec2 = bodyRightPlayer.localToWorld(bitmapPt);
//			bitmapHR.x = pt.x - 7;
//			bitmapHR.y = pt.y - 25;
			
//			var pt_:Vec2 = bodyLeftPlayer.localToWorld(bitmapPt_);
//			bitmapHL.x = pt_.x;
//			bitmapHL.y = pt_.y - 25;
			
		//	var ballPt:Vec2 = body.localToWorld(bitmapBallPt);
			bitmapBall.x = body.position.x //- bodyRadius * Math.cos(body.rotation) + bodyRadius * Math.sin(body.rotation);
			bitmapBall.y = body.position.y //- bodyRadius * Math.sin(body.rotation) - bodyRadius * Math.cos(body.rotation);
			bitmapBall.rotation = body.rotation * 180 / Math.PI;

			 ballFinder.visible = (bitmapBall.y < 0);
			ballFinder.x = bitmapBall.x;

			
				
			if (brpM) {
				brpM.x = bodyRightPlayer.position.x// - 55;
				brpM.y = bodyRightPlayer.position.y - 10;
			}
					
			if (blpM) {
				blpM.x = bodyLeftPlayer.position.x// - 55;
				blpM.y = bodyLeftPlayer.position.y - 20;
			}

				

			//небольшое изменение логики прыжка. Типа немного увеличивается гравитация
			//нужно для того, чтобы игрок не висел долго в воздухе, а быстрее приземлялся и был готов снова прыгать
			if (bodyRightPlayer.velocity.y > -250 && bodyRightPlayer.velocity.y < 250) {
				prevRPlayerYVelocity = bodyRightPlayer.velocity.y;
				bodyRightPlayer.velocity.y += 7;
			}
			if (prevRPlayerYVelocity > 0 && bodyRightPlayer.velocity.y < 0) {
				bodyRightPlayer.velocity.y = 0;
			}
			if (bodyLeftPlayer.velocity.y > -250 && bodyLeftPlayer.velocity.y < 250) {
				prevLPlayerYVelocity = bodyLeftPlayer.velocity.y;
				bodyLeftPlayer.velocity.y += 7;
			}
			if (prevLPlayerYVelocity > 0 && bodyLeftPlayer.velocity.y < 0) {
				bodyLeftPlayer.velocity.y = 0;
			}
			
			if (leftTouchCounter > 3 || rightTouchCounter > 3) {
				//trace(getStopTrippleCounts());
				if(!getStopTrippleCounts()){
					trace("слишком много касаний");
					setStopTrippleCounts(true);
					goal();
				}
			}
			
			//этот подход не работает, надо изменить логику.
			//сейчас получатеся тоже самое но с задержкой
		}
	
		override public function onePlayerAttack():void {
			if(ballPosition < Main.stageWidth / 2){
				if (isBallInLeftAura) {
					roboAttack();
					
					stopTrippleRoboAttackTimer = new Timer(900, 1);
					stopTrippleRoboAttackTimer.addEventListener(TimerEvent.TIMER, stopTrippleRoboAttackListener);
					stopTrippleRoboAttackTimer.start();
			
				}
			}
		}
		
		private function stopTrippleRoboAttackListener(e:TimerEvent):void 
		{
			stopTrippleRoboAttackTimer.removeEventListener(TimerEvent.TIMER, stopTrippleRoboAttackListener);
			isLeftPlayerNotAttacked();
		}
		
		override public function onePlayerJump():void {
			if (ballPosition - playerPosition < 10 && ballPosition - playerPosition > -10) { //сделать трейсы положений мяча и чувака. надо чтобы комп прыгал при сеточном мяче.
				//сделать очередной чит.
				//узнать, сыграл ли противник мяч сидя и прыгнуть через некоторое время.
				//эддэвэнтлистенер(удар сидя)
				addEventListener(Volley.SIT_ATTACK, sitAttackListener);
				setRandomJumpPower();
				heroJumpA();
				trace(ballPosition);
				trace(playerPosition);
			}
		}
		
		override public function rightHeroWin():void {
			MovieClip(brpM).gotoAndPlay(23);
		}
		
		override public function rightHeroLose():void {
			MovieClip(brpM).gotoAndStop(22);
		}
		
		override public function leftHeroWin():void {
			MovieClip(blpM).gotoAndPlay(23);
		}
		
		override public function leftHeroLose():void {
			MovieClip(blpM).gotoAndStop(22);
		}
		
		private function sitAttackListener(e:Event):void 
		{
			//TODO: сделать задержку на секундочку.
			
			jumpOnePlayerDelayTimer = new Timer(900, 1);
			jumpOnePlayerDelayTimer.addEventListener(TimerEvent.TIMER, jumpOnePlayerDelayTimerListener);
			jumpOnePlayerDelayTimer.start();
			
			
		}
		
		private function jumpOnePlayerDelayTimerListener(e:TimerEvent):void 
		{
			jumpOnePlayerDelayTimer.removeEventListener(TimerEvent.TIMER, jumpOnePlayerDelayTimerListener);
			setJumpPower(900);
			heroJumpA();
		}
		
		
		public function roboAttack():void{
			var rx1:Number;
			var ry1:Number;
			var rx2:Number;
			var ry2:Number;
			var rrx:Number;
			var rry:Number;
			
			//trace("2:123");
			
			var raznicaLeftPlayerBallX:Number;
			var raznicaLeftPlayerBallY:Number;
			
			//MovieClip(handLM).play();
			
			if (!isLeftPlayerAttacked) { //если игрок не отпускал клавишу, то второй раз ударить не сможет.
				//if (getFlagIsRallyNow()){ //если мяч в игре, то бить можно.
				//trace("op");
				if (!getFlagIsRallyNow() && isBallInLeftAura) {
					setFlagIsRallyNow(true);
					body.allowMovement = true;
				}
				//определяем позицию героя и мяча
				for (var j:int = 0; j < space.bodies.length; ++j)
				{	
					//координата левого игрока
					if (space.bodies.at(j).cbType.userData == "leftPlayer"){
						rx1 = space.bodies.at(j).position.x;
						ry1 = space.bodies.at(j).position.y;
					}
				
					/*//координата мяча
					if (space.bodies.at(j).cbType.userData == "ball"){
						rx2 = space.bodies.at(j).position.x;
						ry2 = space.bodies.at(j).position.y;
					}
					*/
					rx2 = Main.stageWidth / 2;
					ry2 = Math.random() * (Main.stageHeight / 2);// + (Main.stageHeight / 2);
					
					rrx = rx2 - rx1;
					rry = ry2 - ry1;
					//хууякс
					if ( isBallInLeftAura == true) {
						//trace (wasBallInLeftAura);
//						leftTouchCounter++;
						if (space.bodies.at(j).cbType.userData == "ball") {
							if (blpM) MovieClip(blpM).gotoAndPlay(14);
							
							if (!isLeftPlayerSeat) {
							space.bodies.at(j).velocity.x = 300;
							space.bodies.at(j).velocity.y = 1.5 * (rry + 15);
							}else {
								space.bodies.at(j).velocity.x = 25;
								space.bodies.at(j).velocity.y = -300;
							}
						}
					}
				}
				//}
				if (isBallInLeftAura) {
					if (limiterOftenTouch == 0) {
						limiterOftenTouch = limitOT;
						setRightTouchCounter(0);
						leftTouchCounter++;
					}
				}
			}
			isLeftPlayerAttacked = true;
		}
			
		override public function attack():void{
			var rx1:Number;
			var ry1:Number;
			var rx2:Number;
			var ry2:Number;
			var rrx:Number;
			var rry:Number;
			
			var raznicaLeftPlayerBallX:Number;
			var raznicaLeftPlayerBallY:Number;
			
			//MovieClip(handLM).play();
			
			if (!isLeftPlayerAttacked) { //если игрок не отпускал клавишу, то второй раз ударить не сможет.
				//if (getFlagIsRallyNow()){ //если мяч в игре, то бить можно.
				//trace("op");
				if (!getFlagIsRallyNow() && isBallInLeftAura) {
					setFlagIsRallyNow(true);
					body.allowMovement = true;
				}
				//определяем позицию героя и мяча
				for (var j:int = 0; j < space.bodies.length; ++j)
				{	
					//координата левого игрока
					if (space.bodies.at(j).cbType.userData == "leftPlayer"){
						rx1 = space.bodies.at(j).position.x;
						ry1 = space.bodies.at(j).position.y;
					}
				
					//координата мяча
					if (space.bodies.at(j).cbType.userData == "ball"){
						rx2 = space.bodies.at(j).position.x;
						ry2 = space.bodies.at(j).position.y;
					}
					
					rrx = rx2 - rx1;
					rry = ry2 - ry1;
					//хууякс
					if ( isBallInLeftAura == true) {
						//trace (wasBallInLeftAura);
//						leftTouchCounter++;
						if (space.bodies.at(j).cbType.userData == "ball") {
							if (blpM) MovieClip(blpM).gotoAndPlay(14);
							
							if (!isLeftPlayerSeat) {
							space.bodies.at(j).velocity.x = 8 * rrx;
							space.bodies.at(j).velocity.y = 6 * (rry + 15);
							}else {
								space.bodies.at(j).velocity.x = 25;
								space.bodies.at(j).velocity.y = -300;
							}
						}
					}
				}
				//}
				if (isBallInLeftAura) {
					if (limiterOftenTouch == 0) {
						limiterOftenTouch = limitOT;
						setRightTouchCounter(0);
						leftTouchCounter++;
					}
				}
			}
			isLeftPlayerAttacked = true;
		}
		
		override public function blpGoToRight():void {
			if (blpM) {
				if (blpM.currentFrame < 12) {
					blpM.nextFrame();
				} else {
					blpM.gotoAndStop(0);
				}
			}
		}
		
		override public function blpGoToLeft():void {
			if (blpM) {
				//brpM.play();
				if (blpM.currentFrame > 1 && blpM.currentFrame < 13) {
					blpM.prevFrame();
				} else {
					blpM.gotoAndStop(12);
				}
			}
		}
		
		override public function brpGoToRight():void {
			if (brpM) {
				//brpM.play();
				if (brpM.currentFrame < 12) {
					brpM.nextFrame();
				} else {
					brpM.gotoAndStop(0);
				}
			}
		}
		
		override public function brpGoToLeft():void {
			if (brpM) {
				//brpM.play();
				if (brpM.currentFrame > 1 && brpM.currentFrame < 13) {
					brpM.prevFrame();
				} else {
					brpM.gotoAndStop(12);
				}
			}
		}
		
		override public function leftPlayerSeat():void {
			if (blpM) {
				blpM.gotoAndStop(21);
			}
			isLeftPlayerSeat = true;
		}
		
		override public function rightPlayerSeat():void {
			if (brpM) {
				brpM.gotoAndStop(21);
			}
			isRightPlayerSeat = true;
		}
		
		override public function leftPlayerIsNotSeat():void {
			isLeftPlayerSeat = false;
		}
		
		override public function rightPlayerIsNotSeat():void {
			isRightPlayerSeat = false;
		}
		
		override public function brpStop():void {
			if (brpM) {
				//brpM.stop();
				//trace("stop");
			}
		}
		
		override public function attackR():void	{
			var rx1:Number;
			var ry1:Number;
			var rx2:Number;
			var ry2:Number;
			var rrx:Number;
			var rry:Number;
			
			//trace(isBallInRightAura);
			
			var raznicaRightPlayerBallX:Number;
			var raznicaRightPlayerBallY:Number;
			
			
			
			if (!isRightPlayerAttacked) {
				for (var j:int = 0; j < space.bodies.length; ++j)
				{	
					//TODO: добавить сюда звук удара по мячу
					if (space.bodies.at(j).cbType.userData == "rightPlayer")
					{
						rx1 = space.bodies.at(j).position.x;
						ry1 = space.bodies.at(j).position.y;
					}
				
					if (space.bodies.at(j).cbType.userData == "ball")
					{
						rx2 = space.bodies.at(j).position.x;
						ry2 = space.bodies.at(j).position.y;
					}
				
					rrx = rx2 - rx1;
					rry = ry2 - ry1;
					//trace (rrx-30);
					//trace (rry);
				
					if ( isBallInRightAura == true) {
						if (space.bodies.at(j).cbType.userData == "ball") {
							if (brpM) MovieClip(brpM).gotoAndPlay(14);
							
							
							if (!isRightPlayerSeat) { //если игрок стоит то обычный удар
								space.bodies.at(j).velocity.x = 8 * rrx;
								space.bodies.at(j).velocity.y = 6 * (rry + 15);
							} else { //а если сидит
								space.bodies.at(j).velocity.x = -25;//немного двигаем мяч влево, чтобы можно было тупо подпрыгнуть вверх и ударить.
								space.bodies.at(j).velocity.y = -300;//когда идет прием снизу - мяч подлетает на одну и ту же высоту для простоты нападения
								dispatchEvent(new Event(SIT_ATTACK));
							}
						}
					}
				}
				if (isBallInRightAura) {
					if (limiterOftenTouch == 0) {
						limiterOftenTouch = limitOT;
						setLeftTouchCounter(0);
						rightTouchCounter++;
					}
				}
			}
			isRightPlayerAttacked = true;
		}
		
		override public function blpJump():void {
			if (blpM) blpM.gotoAndStop(13);
		}
		
		override public function brpJump():void {
			if (brpM) {
				//brpM.gotoAndPlay(16);
				//for (var i:int = 16; i < 35; i++)
				brpM.gotoAndStop(13);
				/*if (brpM.currentFrame < 34) {
					brpM.nextFrame();
				} else {
					brpM.stop();
				}*/
			}
		}
		override public function isLeftPlayerNotAttacked():void {
			isLeftPlayerAttacked = false;
		}
		
		override public function isRightPlayerNotAttacked():void {
			isRightPlayerAttacked = false;
		}
		
		override public function newRally(x_:int):void {
			setLeftTouchCounter(0);
			setRightTouchCounter(0);
			setFlagIsRallyNow(false);
			setStopTrippleCounts(false);
			setStopGoals(false);
			//trace (RPlayerOnFloor);
			//trace (LPlayerOnFloor);
			//if (RPlayerOnFloor && LPlayerOnFloor) {
			for (var i:int = 0; i < space.bodies.length; ++i){
				if(space.bodies.at(i) && space.bodies.at(i).cbType && space.bodies.at(i).cbType.userData)
				if (space.bodies.at(i).cbType.userData == "ball"){
					space.bodies.at(i).position.y = 200;
					space.bodies.at(i).position.x = x_;
					space.bodies.at(i).velocity = new Vec2(0, 0);
					space.bodies.at(i).allowMovement = false;
				}
			}
			//}
			//сюда добавить удаление слушателя, который слушает что оба игрока на полу.
		}
		
		override public function tabloUpdate(leftScoreT:int = 0, rightScoreT:int = 0):void {
			//tabloM.gotoAndStop(tabloM.currentFrame + 1);
			tabloDigitLeftOneM.gotoAndStop(leftScoreT % 10 + 1);
			tabloDigitLeftTenM.gotoAndStop(Math.floor(leftScoreT / 10) + 1);
			trace(rightScoreT + " " + rightScoreT / 10 + " " + Math.floor(rightScoreT / 10));
			tabloDigitRightOneM.gotoAndStop(rightScoreT % 10 + 1);
			tabloDigitRightTenM.gotoAndStop(Math.floor(rightScoreT / 10) + 1);
		}
			
		override public function createGround():void {

			var backgroundBitmap:BitmapData = (new GFX.BackgroundSprite()).bitmapData;
			bitmap = new Bitmap(backgroundBitmap);
			
//			var ballBitmap:BitmapData = (new GFX.BallSprite()).bitmapData;
			bitmapBall = new Ball();
			tabloDigitLeftOneM = new tableNumbers();
			tabloDigitLeftTenM = new tableNumbers();
			tabloDigitRightTenM = new tableNumbers();
			tabloDigitRightOneM = new tableNumbers();

			layout();
			addChildren();
		}

	private function addChildren(): void {
		overlaySprite.addChild(bitmap);
		overlaySprite.addChild(bitmapBall);
		overlaySprite.addChildAt(tabloDigitLeftTenM, 1);
		overlaySprite.addChildAt(tabloDigitLeftOneM, 1);
		overlaySprite.addChildAt(tabloDigitRightTenM, 1);
		overlaySprite.addChildAt(tabloDigitRightOneM, 1);

	}

	private function layout(): void {
		bitmap.y = 0;
		bitmap.alpha = 1; //0.3 для тестов


		tabloDigitLeftOneM.x = 280;
		tabloDigitLeftOneM.y = 100;
		tabloDigitLeftTenM.y = 100;
		tabloDigitLeftTenM.x = 220;
		tabloDigitRightOneM.x = 425;
		tabloDigitRightOneM.y = 100;
		tabloDigitRightTenM.x = 365;
		tabloDigitRightTenM.y = 100;
	}
	}
}