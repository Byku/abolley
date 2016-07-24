package  
{
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.Timer;

import nape.callbacks.CbType;
import nape.constraint.*;
	import nape.phys.*;
	import nape.shape.*;
	import nape.space.*;
	import nape.geom.*;
	import Tests.*;
	
	public class Test extends MovieClip
	{
		public var space:Space = new Space; 
		public var name1:String;
			
		public static const GAME_OVER:String = "gameOver";
		
		
		//определяет высоту прыжка героя
		public var jumpPower:Number = 400;
		
		//определяет, идет ли сейчас розыгрыщ или сейчас пауза
		private var isRallyNow:Boolean;
		
		//переменная, чтобы многократно не срабатывала остановка игры из-за многократных касаний
		private var stopTrippleCounts:Boolean;
		
		//переменная чтобы нормально обрабатывался гол
		private var stopGoals:Boolean;
		
		//определяет высоту прыжка антигероя
		public var jumpPowerA:Number = 400;
		
		public var scoreCounter:int = 0;
		
		//определяет, куда идти компьютеру
		public var ballPosition:Number;
		public var playerPosition:Number
		
		//максимальная высота прыжка
		private const maxJumpPower:Number = 950;
		private const stepJumpPowerAdd:Number = 50;
		
		private const maxScoreOfSet:Number = 15; //игра идет до 15 очков
		
		//draw anything here
		public var overlaySprite:Sprite = new Sprite;

		//used for dragging
		private var mouseJoint:PivotJoint = null;
		
		private var leftScore:int = 0;
		private var rightScore:int = 0;
		
		//нужен для того, чтобы сделать задержку между голом и началом нового розыгрыша
		private var timer4newRally:Timer;
		
		
		public function Test(name1:String, gravity:Number = 200)
		{ 
			this.name = name1;
			space.gravity = new Vec2(0, gravity);
		}
		
		public function getFlagIsRallyNow():Boolean {
			return isRallyNow;
		}
		
		public function setFlagIsRallyNow(bool:Boolean):void {
			isRallyNow = bool;
		}
		
		public function getStopTrippleCounts():Boolean {
			return stopTrippleCounts;
		}
		
		public function setStopTrippleCounts(bool:Boolean):void {
			stopTrippleCounts = bool;
		}
		
		public function getStopGoals():Boolean {
			return stopGoals;
		}
		
		public function setStopGoals(bool:Boolean):void {
			stopGoals = bool;
		}
		public function changeScore():int {
			//tab.tablo();
			//trace(tab.getScoreLeft());
			for (var i:int = 0; i < space.bodies.length; ++i)
				{		
					if (space.bodies.at(i).cbType.userData == "ball")
					{
						if (space.bodies.at(i).position.x > 325) {
							leftScore++;
							return (150);
							
						} else {
							rightScore++;
							return (500);
						}
					}
				}
				
			return 1;
		}
		
		
		//override
		public function update():void { }
		public function attack():void { }
		public function attackR():void { }
		public function onePlayerAttack():void { }
		public function onePlayerJump():void {}
		public function isLeftPlayerNotAttacked():void { }
		public function isRightPlayerNotAttacked():void { }
		public function createUI(parent:VBox):void { }
		public function createGround():void { }
		public function tabloUpdate(leftScoreT:int = 0, rightScoreT:int = 0):void 	{	}
		public function rightHeroWin():void { }
		public function rightHeroLose():void { }
		public function leftHeroWin():void { }
		public function leftHeroLose():void { }
		
		public function blpGoToRight():void { }
		public function blpGoToLeft():void { }
		public function brpGoToRight():void { }
		public function brpGoToLeft():void { }
		public function brpStop():void { }
		public function leftPlayerSeat():void { }
		public function leftPlayerIsNotSeat():void { }
		public function rightPlayerSeat():void { }
		public function rightPlayerIsNotSeat():void { }
		public function hideBall():void { }
		//public function newSet2():void { } 
		
		
		public function newSet():void { 
			newRally(150);
			rightScore = 0;
			leftScore = 0;
			tabloUpdate();
			//trace("123123");
			//newSet2();
		}
		
		
//////////////////////////////////////если мяч коснулся земли//////////////
//эта функция должна: останавливать мяч ( и, может быть, добавлять анимацию, показывающую что произошел гол)
//изменять счет (запускать функцию по изменению счета)
//запускать новый розыгрыш либо заканчивать игру, в зависимости от счета.
		private function stopBallOnGoal():void {
			setFlagIsRallyNow(false); // розыгрыш закончился
			for (var i:int = 0; i < space.bodies.length; ++i){		
				if (space.bodies.at(i).cbType.userData == "ball"){
					//сюда надо сделать красивое останавливание мяча на пару секунд, свисток и анимацию
					//space.bodies.at(i).velocity.y = 0;
					//space.bodies.at(i).velocity.x = 0;
					space.bodies.at(i).velocity = new Vec2(0, 0);
					space.bodies.at(i).allowMovement = false;
				}
			}
			
		}
		
		//новый розыгрыш мяча
		public function newRally(x_:int):void {
		}
		
		//обновление табло
		private function updateScoreboard(score_:int):void {
			trace("табло обновлено");
			//inputfield.text = String(leftScore);
		}
		
		public function getLeftScore():int {
			return (leftScore);
		}
		
		public function getRightScore():int {
			return rightScore;
		}
		
		//конец партии
		public function endOfGame():void {
			//спрятать мяч
			newRally( -100);
		}
		
		public function startAI():void {
			for (var i:int = 0; i < space.bodies.length; ++i){		
				if (space.bodies.at(i).cbType.userData == "ball"){
					trace(space.bodies.at(i).position.x);
					return;
				}
			}
		}

	
		public function goal():void {

			setStopGoals(true);
			for (var i:int = 0; i < space.bodies.length; ++i){		
				if (space.bodies.at(i).cbType.userData == "ball"){
					space.bodies.at(i).position.y -= 5;
					//space.bodies.at(i).position.x -= 1;
					space.bodies.at(i).velocity = new Vec2(0, 0);
					space.bodies.at(i).allowMovement = false;
				}
			}
				stopBallOnGoal();
				scoreCounter = changeScore();
				
				tabloUpdate(leftScore, rightScore);
				
				timer4newRally = new Timer(800, 1);
				timer4newRally.addEventListener(TimerEvent.TIMER, timer4newRallyListener);
				timer4newRally.start();
				updateScoreboard(scoreCounter);

//TODO: Добавить сюда слушатель, который ждет пока оба игрока окажутся на полу.
//после этого запускается начало нового раунда
					
		}
			
			private function timer4newRallyListener(e:TimerEvent):void 
			{				
			timer4newRally.removeEventListener(TimerEvent.TIMER, timer4newRallyListener);
			setStopTrippleCounts(true);
			setFlagIsRallyNow(false);
				//timer4newRally.stop();
				if (leftScore < maxScoreOfSet && rightScore < maxScoreOfSet){ 
					//trace("запуск функции начала нового розыгрыша");
					newRally(scoreCounter);
				} else if (leftScore >= maxScoreOfSet && ((leftScore - rightScore) > 1)) {
					trace("запуск функции окончания партии, выиграл левый");
					rightHeroLose();
					leftHeroWin();
					//запуск меню из майна и отображение баннера с победителем
					dispatchEvent(new Event(Test.GAME_OVER));
					
				} else if (rightScore >= maxScoreOfSet && ((rightScore - leftScore) > 1)) {
					trace("запуск функции окончания партии, выиграл правый");
					rightHeroWin();
					leftHeroLose();
					//запуск меню из майна и отображение баннера с победителем
					dispatchEvent(new Event(Test.GAME_OVER));
					//запустить таймер на 2-3 секунды а потом эндоф гейм
					
				} else if (rightScore >= (maxScoreOfSet - 1) && leftScore >= (maxScoreOfSet - 1) && (((rightScore - leftScore) <= 1) || ((leftScore - rightScore) < 2))) {
					//trace("запуск функции начала нового розыгрыша");
					newRally(scoreCounter);
				} else	{ trace ("ошибка"); }

			}
			

			
/////////////////////////////////////движение компа/////////////////////
		public function onePlayerMove ():void {
			
			for (var i:int = 0; i < space.bodies.length; ++i){
				if (space.bodies.at(i).cbType) {
					if (space.bodies.at(i).cbType.userData == "ball") {
						//if (space.bodies.at(i).position.x > Main.stageWidth / 2){
						ballPosition = space.bodies.at(i).position.x;
						//}
					}
					if (space.bodies.at(i).cbType.userData == "leftPlayer") {
						playerPosition = space.bodies.at(i).position.x;
					}
				}
			}
			//
			//trace(ballPosition + ' ' + playerPosition);
			//trace(Main.stageWidth - ballPosition - playerPosition);
			
			//сделать атаку компа читерской. чтобы комп случайным образом определял, посылать мяч низко над сеткой или парашютиком.
			//тогда можно не заморачиваться на счет выбора позиции компа относительно мяча. т.к. нормально работает только сейчас почему то
			//научить комп прыгать.(как минимум, при проверке, что это начало партии)
			
			if (ballPosition > Main.stageWidth / 2){
				if ((Main.stageWidth - ballPosition - playerPosition) > 10){
					heroMoveTo(Main.stageWidth - ballPosition);
				} 
				else if ((Main.stageWidth - playerPosition - ballPosition) < -10){
					heroMoveTo(Main.stageWidth - ballPosition);
				}
			} else if (ballPosition < Main.stageWidth / 2){
				if ((ballPosition - playerPosition) > 10){
					heroMoveTo(ballPosition);
				} else if ((ballPosition - playerPosition) < -10){
					heroMoveTo(ballPosition);
				}
			}
		}
		
		public function heroMoveTo(xTo:Number):void {
			for (var i:int = 0; i < space.bodies.length; ++i){
				if (space.bodies.at(i).cbType.userData == "leftPlayer"){
					if (space.bodies.at(i).position.x > xTo) {
						heroMove(65);
					} else if (space.bodies.at(i).position.x < xTo) {
						heroMove(68);
					}
				}
			}
		}
/////////////////////////////////////движение героя/////////////////////
		public function heroMove(_keyCode:Number):void
		{
			//trace(_keyCode);
			if (_keyCode == 37) //движение правого героя влево
			{
				for (var i:int = 0; i < space.bodies.length; ++i){
					if (space.bodies.at(i).cbType.userData == "rightPlayer"){
						if(space.bodies.at(i).position.x > 380){
							space.bodies.at(i).velocity.x = -200;
							brpGoToLeft();
							rightPlayerIsNotSeat();
						}
					}
				}
			}
			
			if (_keyCode == 39) //движение правого героя вправо
			{
				for (var j:int = 0; j < space.bodies.length; ++j){	
					if (space.bodies.at(j).cbType.userData == "rightPlayer"){
						if(space.bodies.at(j).position.x < 610){
							space.bodies.at(j).velocity.x = 200;
							brpGoToRight();
							rightPlayerIsNotSeat();
						}
					}
				}
			}
		
			if (_keyCode == 68) //движение левого героя вправо
			{
				for (var k:int = 0; k < space.bodies.length; ++k){	
					if (space.bodies.at(k).cbType.userData == "leftPlayer") {
						if (space.bodies.at(k).position.x < 260) {
							space.bodies.at(k).velocity.x = 200;
							blpGoToRight();
							leftPlayerIsNotSeat();
						}
					}
				}
			}
			
			if (_keyCode == 65) //движение левого героя влево
			{
				for (var m:int = 0; m < space.bodies.length; ++m){
					if (space.bodies.at(m).cbType.userData == "leftPlayer"){
						if (space.bodies.at(m).position.x > 30) {
							space.bodies.at(m).velocity.x = -200;
							blpGoToLeft();
							leftPlayerIsNotSeat();
						}
					}
				}
			}
		}
		
		public function setJumpPower(power:int):void {
			jumpPowerA = power;
		}
		
		public function setRandomJumpPower():void {
			if (!getFlagIsRallyNow()) {
				jumpPowerA = 700;
			} else {
			jumpPowerA = Math.random() * 350 + 600;
			}
			trace(jumpPowerA);
		}
		
		public function addJumpPower(a:Number):void 
		{
			
			if (a == 38) // наращивание силы прыжка героя
			{
				if (jumpPower < maxJumpPower){
					jumpPower += stepJumpPowerAdd;
				} else {
					jumpPower = maxJumpPower;
				}
			}
			
			if (a == 87) // наращивание силы прыжка антигероя
			{
				if (jumpPowerA < maxJumpPower){
					jumpPowerA += stepJumpPowerAdd;
				} else {
					jumpPowerA = maxJumpPower;
				}
			}
		}
		
		public function heroStop():void	{
			for (var i:int = 0; i < space.bodies.length; ++i)
				{
					if(space.bodies.at(i) && space.bodies.at(i).cbType && space.bodies.at(i).cbType.userData)
						if (space.bodies.at(i).cbType.userData == "rightPlayer")
					{
						space.bodies.at(i).velocity.x = 0;
						//brpStop();
					}
				}
		}
		
		public function antiheroStop():void	{
			for (var i:int = 0; i < space.bodies.length; ++i)
				{
					if(space.bodies.at(i) && space.bodies.at(i).cbType && space.bodies.at(i).cbType.userData)
						if (space.bodies.at(i).cbType.userData == "leftPlayer")
					{
						space.bodies.at(i).velocity.x = 0;
					}
				}
		}


		//прыжок правого игрока
		public function heroJump():void { 
			for (var j:int = 0; j < space.bodies.length; ++j)
			{	
				if (space.bodies.at(j).cbType.userData == "rightPlayer")
				{
					if (space.bodies.at(j).position.y > 300)
					{
						space.bodies.at(j).velocity.y = jumpPower * 2;
						brpJump(); //графика героя при прыжке
						rightPlayerIsNotSeat();
					}
				}
			}
			jumpPower = 400;
		}

		public function brpJump():void { }
		
		//прыжок игрока
		public function heroJumpA():void {
			for (var j:int = 0; j < space.bodies.length; ++j)
			{	
				if (space.bodies.at(j).cbType.userData == "leftPlayer")
				{
					if (space.bodies.at(j).position.y > 300)
					{
						space.bodies.at(j).velocity.y = jumpPowerA * 2;
						blpJump();
						leftPlayerIsNotSeat();
					}
				}
			}
			jumpPowerA = 400;
		}

		public function blpJump():void { }
		
	/*	
		//by default user can drag objects
		public function mouseDown(pt:Vec2):void 
		{
			var bodyList:BodyList = space.bodiesUnderPoint(pt);
			var body:Body = null;
			for (var i:int = 0; i < bodyList.length; ++i)
			{
				if (bodyList.at(i).isDynamic())
				{
					body = bodyList.at(i);
					break;
				}
			}
			if (body)
			{
				mouseJoint = new PivotJoint(space.world, body, pt, body.worldToLocal(pt));
				mouseJoint.space = space;
				mouseJoint.stiff = false;
				mouseJoint.maxForce = body.mass * 10000;
			}
		}
		
		public function mouseUp(pt:Vec2):void 
		{ 
			if (mouseJoint)
			{
				mouseJoint.space = null;
				mouseJoint = null;
			}
		}

		public function mouseMove(pt:Vec2, buttonDown:Boolean):void 
		{ 
			if (mouseJoint)
			{
				if (!buttonDown)
					mouseUp(pt);
				else
					mouseJoint.anchor1 = pt;
			}
		}*/
		
		//create walls
		public function createWalls(material:Material):Body
		{
			var walls:Body = new Body(BodyType.STATIC);
			//walls.shapes.add(new Polygon(Polygon.rect( -Main.stageWidth, -Main.stageHeight, Main.stageWidth * 3, Main.stageHeight - 1), material));
			walls.shapes.add(new Polygon(Polygon.rect( -Main.stageWidth, Main.stageHeight-100, Main.stageWidth * 3, Main.stageHeight), material));
			walls.shapes.add(new Polygon(Polygon.rect( -Main.stageWidth, -Main.stageHeight * 2, Main.stageWidth - 1, Main.stageHeight * 3), material));
			walls.shapes.add(new Polygon(Polygon.rect( Main.stageWidth, -Main.stageHeight * 2, Main.stageWidth, Main.stageHeight * 3), material));
			walls.shapes.add(new Polygon(Polygon.rect( Main.stageWidth / 2 - 5, Main.stageHeight / 2, 10, Main.stageHeight / 2), material)); 

			var cbType : CbType = new CbType();
			cbType.userData = "wall";
			walls.cbType = cbType;

			walls.space = space;

			return walls;
		}
		
		
		
	}

}