package Tests 
{
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import nape.dynamics.InteractionFilter;

	import nape.callbacks.CbType;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.phys.BodyType;
	import nape.geom.*;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.constraint.DistanceJoint;
	import nape.dynamics.Arbiter;
	
	
	public class Volley extends Test 
	{
		private var body:Body;
		private var bodyH:Body;
		private var bodyA:Body;
		private var bodyLeftPlayer:Body;
		private var bodyRightPlayer:Body;
		private var bodyAura:Body;
		private var bodyKinematicFloor:Body;
		
		private var netArray:Array;
		public var heroType:CbType;
		private var distJoint:DistanceJoint;
		
		//фильтры столкновений
		private var filter1:InteractionFilter = new InteractionFilter(0x001, ~0x001, 0x100, 0x100);
		private var filterBall:InteractionFilter = new InteractionFilter(0x001, 0x001, 0x100, 0x100);
		private var filterFloor:InteractionFilter = new InteractionFilter(0x001, ~0x001, 0x100, 0x100);
		private var filterHero:InteractionFilter = new InteractionFilter(0x001, 0x001, 0x100, 0x100);
	//	private var firstSensorGroup:int = 0x00000001;
		
		private var bitmap:Bitmap;
		private var bitmap_:Bitmap;
		//private var body:Body;
		private var bitmapPt:Vec2;
		private var bitmapPt_:Vec2;
		
		[Embed(source="../../lib/SnegovikStoit.swf",mimeType="application/octet-stream" )]
		private var HeroStoit:Class; 
		private var heroStoitM:MovieClip;
		private var ldrS:Loader;
		
		[Embed(source="../../lib/SnegovikStoitZ.swf",mimeType="application/octet-stream" )]
		private var AntiHeroStoit:Class; 
		private var antiHeroStoitM:MovieClip;
		private var ldrAntiHeroS:Loader;
		
		public function Volley() 
		{
			super("Volley");
			createWalls(Material.steel());
			heroType = new CbType();
			heroType.userData = "blabla";
			
//////////////////////////////////////////////////////создаем тестовую ауру//////////////////
			bodyAura = new Body(BodyType.KINEMATIC, new Vec2(200, 200));
			bodyAura.shapes.add(new Circle(50, new Vec2(0, 0), Material.glass(), filter1));
			bodyAura.space = space;
//////////////////////////////////////////////////////кончили создавать ауру/////////////////

//////////////////////////////////////////////////////создаем слой, который определит касание пола мячом//////////////
			bodyKinematicFloor = new Body(BodyType.KINEMATIC, new Vec2(0, 379));
			bodyKinematicFloor.shapes.add(new Polygon(Polygon.rect(0, 0, 640, 1), Material.steel(), filterFloor));
			bodyKinematicFloor.space = space;

//////////////////////////////////////////////////////кончили создавать слой, который определит касание пола мячом//////////////
//////////////////////////////////////////////////////////создаем мяч////////////////////////			
			body = new Body(BodyType.DYNAMIC, new Vec2(400, 300));
			body.shapes.add(new Circle(30, new Vec2(0, 0), Material.rubber(),filterBall));
			heroType.userData = "ball";
			body.cbType = heroType;
			body.align();
			body.allowRotation = true;
			body.space = space;
			
/////////////////////////////////////////////////////кончили создавать мяч////////////////////


/////////////////////////////////////////////////////создаем левого игрока////////////////////

			bodyLeftPlayer = new Body(BodyType.DYNAMIC, new Vec2(50, 150));
			bodyLeftPlayer.shapes.add(new Polygon(Polygon.rect(0, 0, 50, 70), Material.steel(), filterHero));
			bodyLeftPlayer.shapes.add(new Circle(25, new Vec2(25, 5), Material.steel(), filterHero));
			heroType = new CbType();
			heroType.userData = "leftPlayer";
			bodyLeftPlayer.cbType = heroType;
			bodyLeftPlayer.allowRotation = false;
			bodyLeftPlayer.space = space;
/////////////////////////////////////////////////////кончили создавать левого игрока//////////
//////////////////////////////////////////////////////////создаем героя//////////////////////			
			ldrS = new Loader();
			ldrS.loadBytes(new HeroStoit as ByteArray);
			//ldrS.contentLoaderInfo.addEventListener(Event.INIT, heroStoitInitListener);
			overlaySprite.addChild(ldrS);
			
			var scale:Number = 2;
			
			[Embed(source = "snegovik.png")]
			var Img:Class;
			var bitmapData:BitmapData = (new Img()).bitmapData;
			bitmap = new Bitmap(bitmapData);
			bitmap.alpha = 0.1;
			bitmap.scaleX = bitmap.scaleY = scale;
			overlaySprite.addChild(bitmap);

			function f(x:Number, y:Number):Number
			{
				return ((bitmapData.getPixel32(x / scale, y / scale) >> 24) & 0xff) > 0xA0 ? -1 : 1;
				//return 1;
			}
			
			var polyList:GeomPolyList = MarchingSquares.run(f, new AABB(0, 0, bitmapData.width*scale, bitmapData.height*scale), new Vec2(10, 10), 1, null, true);
			
			bodyH = new Body(BodyType.DYNAMIC, new Vec2(Main.stageWidth / 2, Main.stageHeight / 2));
			for (var i:int = 0; i < polyList.length; ++i)
			{
				var polyList2:GeomPolyList = polyList.at(i).convex_decomposition();
				for (var j:int = 0; j < polyList2.length; ++j)
				{
					bodyH.shapes.add(new Polygon(polyList2.at(j), Material.steel(), filterHero));
				}
			}
			bitmapPt = bodyH.localToWorld(new Vec2());
			bodyH.allowRotation = false;
			bodyH.align();
			heroType = new CbType();
			heroType.userData = "antihero2";
			bodyH.cbType = heroType;
			
			bitmapPt = bodyH.worldToLocal(bitmapPt);
			bodyH.position.x = 90;
			bodyH.space = space;
/////////////////////////////////////////////////////////////конец создания героя//////////////			
			

//////////////////////////////////////////////////////////создаем антигероя//////////////////////			
			ldrAntiHeroS = new Loader();
			ldrAntiHeroS.loadBytes(new AntiHeroStoit as ByteArray);
			//ldrS.contentLoaderInfo.addEventListener(Event.INIT, heroStoitInitListener);
			overlaySprite.addChild(ldrAntiHeroS);
			
			//var scale:Number = 2;
			
			[Embed(source = "antisnegovik.png")]
			var Img_:Class;
			bitmapData = (new Img_()).bitmapData;
			bitmap_ = new Bitmap(bitmapData);
			bitmap_.alpha = 0.0;
			bitmap_.scaleX = bitmap_.scaleY = scale;
			overlaySprite.addChild(bitmap_);

			function ff(x:Number, y:Number):Number
			{
				return ((bitmapData.getPixel32(x / scale, y / scale) >> 24) & 0xff) > 0xA0 ? -1 : 1;
				//return 1;
			}
			
			var polyList_:GeomPolyList = MarchingSquares.run(ff, new AABB(0, 0, bitmapData.width*scale, bitmapData.height*scale), new Vec2(10, 10), 1, null, true);
			
			bodyA = new Body(BodyType.DYNAMIC, new Vec2(Main.stageWidth / 2, Main.stageHeight / 2));
			for (var i:int = 0; i < polyList_.length; ++i)
			{
				var polyList2_:GeomPolyList = polyList_.at(i).convex_decomposition();
				for (var j:int = 0; j < polyList2_.length; ++j)
				{
					bodyA.shapes.add(new Polygon(polyList2_.at(j), Material.steel(), filterBall));
				}
			}
			bitmapPt_ = bodyA.localToWorld(new Vec2());
			bodyA.allowRotation = false;
			bodyA.align();
			heroType = new CbType();
			heroType.userData = "hero";
			bodyA.cbType = heroType;

			
			bitmapPt_ = bodyA.worldToLocal(bitmapPt_);
			bodyA.position.x = 450;
			bodyA.space = space;
			//bodyA.graphic.alpha = 1.0;
/////////////////////////////////////////////////////////////конец создания антигероя//////////////			

		}
		
		override public function update():void
		{
					var pt_:Vec2 = bodyA.localToWorld(bitmapPt_);
			bitmap_.x = pt_.x;
			bitmap_.y = pt_.y;
			
			ldrAntiHeroS.x = bitmap_.x;
			ldrAntiHeroS.y = bitmap_.y;	
			
			
			var pt:Vec2 = bodyH.localToWorld(bitmapPt);
			bitmap.x = pt.x;
			bitmap.y = pt.y;
			bitmap.rotation = bodyH.rotation * 180 / Math.PI;
			
			ldrS.x = bitmap.x;
			ldrS.y = bitmap.y;
			ldrS.rotation = bitmap.rotation;
			
			bodyAura.position.x = bodyLeftPlayer.position.x+25;
			bodyAura.position.y = bodyLeftPlayer.position.y;

			
			//goal();
			
			//trace(bodyA.arbiters.length);
			 for(var i = 0; i<body.arbiters.length; i++)
			{
				var arb:Arbiter = body.arbiters.at(i);

				if (arb.isSensorArbiter() && (arb.body1 == bodyAura||arb.body2 == bodyAura ))
				{
					trace("столкновение с аурой");
				}
			
				if (arb.isSensorArbiter() && (arb.body1 == bodyKinematicFloor||arb.body2 == bodyKinematicFloor ))
				{
					goal();
				}

			}
			
			/*for(var i = 0; i<body.arbiters.length; i++)
			{
				var arb:Arbiter = body.arbiters.at(i);
				//trace(arb.isSensorArbiter());
				//trace(arb.body1 + " " + arb.body2);
				//trace(bodyH);
				trace(body.arbiters.at(i));

				if ((arb.body1 == bodyH&&arb.body2 == bodyKinematicFloor)||(arb.body1 == bodyKinematicFloor||arb.body2 == bodyH ))
				{
					trace("столкновение тела с полом");
				}
			
			}*/

			
		}
		
	}

}