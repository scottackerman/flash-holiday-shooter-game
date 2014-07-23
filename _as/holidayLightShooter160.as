package {
	import flash.net.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.display.*;
	import flash.external.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
	import com.sebleedelisle.*;
	
	public class holidayLightShooter160 extends MovieClip {
		TweenPlugin.activate([TintPlugin, BezierThroughPlugin, BezierPlugin, GlowFilterPlugin, AutoAlphaPlugin]);
		
		private var bitmapData:BitmapData = new BitmapData(151,151);
		private var colorTransform:ColorTransform = new ColorTransform();
		private var hexColor:* = 0xffffff;
		
		private var particles:Array = new Array();
		private var spareParticles:Dictionary = new Dictionary(); 
		private var particle:Particle;
		private var counter:Number = 0;
		private var shooting:Boolean;
		
		private var smokeSprite = new Sprite(); 
		private var sparkSprite = new Sprite();
		
		private var spaceBarKey:uint = 32;
		private var leftArrowKey:uint = 37;
		private var upArrowKey:uint = 38;
		private var rightArrowKey:uint = 39;
		private var downArrowKey:uint = 40;
		private var leftMax:int = -40;
		private var upMax:Number = 1.12;
		private var rightMax:int = 40;
		private var downMax:Number = .78;
		private var leftRightInc:uint = 3;
		private var upDownInc:Number = .01;
		private var targetGlobalCoordinates:Point;
		private var xTrajectoryOffset:Number;
		private var yTrajectoryOffset:Number;
		private var xTrajectoryMidArcOffset:Number = .7;
		private var shootingSpeed:Number = 2.5;
		
		private var blinkers:Boolean;
		private var optionsOpen:Boolean;
		private var gameOver:Boolean;
		private var autoPlaying:Boolean;
		
		private var selectedOption:MovieClip;
		
		private var targetMidArcX:Number;
		private var targetMidArcY:Number;
		private var targetDestinationX:Number;
		private var targetDestinationY:Number;
		
		private var gameTime:Number = 13;
		
		private var scoreIncrement:Number = 250;
		private var currentScore:Number = 0;
		
		public function holidayLightShooter160() {
			endFrame_mc.visible = false;
			legalBtn_mc.addEventListener(MouseEvent.ROLL_OVER, legalRollOverEvent);
			legalBtn_mc.addEventListener(MouseEvent.ROLL_OUT, legalRollOutEvent);
			branding_mc.addEventListener(MouseEvent.CLICK, mainClickEvent);
			hit_mc.addEventListener(MouseEvent.CLICK, mainClickEvent);
			endFrame_mc.endHit_mc.addEventListener(MouseEvent.CLICK, mainClickEvent);
			cta_mc.addEventListener(MouseEvent.CLICK, killAutoPlay);
			endFrame_mc.playAgain_mc.addEventListener(MouseEvent.CLICK, restartGame);
			innerOptions_mc.lightIcon_mc.addEventListener(MouseEvent.CLICK, setLightOnOption);
			innerOptions_mc.blinkLightIcon_mc.addEventListener(MouseEvent.CLICK, setLightBlinkOption);
			bitmapData.draw(outerOptions_mc.spectrum_mc);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownListener);
			hit_mc.buttonMode = legalBtn_mc.buttonMode = branding_mc.buttonMode = cta_mc.buttonMode = innerOptions_mc.lightIcon_mc.buttonMode = innerOptions_mc.blinkLightIcon_mc.buttonMode = outerOptions_mc.spectrum_mc.buttonMode = endFrame_mc.playAgain_mc.buttonMode = endFrame_mc.endHit_mc.buttonMode = true;
			smokeSprite.filters = [new BlurFilter(5,5,1)];
			xTrajectoryOffset = (stage.stageWidth/2)/rightMax;
			updateTargetPath();
			initBanner();
			innerOptions_mc.blinkLightIcon_mc.lamp_mc.blinkers = true;
			startBlink(innerOptions_mc.blinkLightIcon_mc.lamp_mc.bulb_mc);
			selectedOption = innerOptions_mc.lightIcon_mc.iconBg_mc;
			highlightSelectedOption(selectedOption);
		}
		
		private function initBanner():void {
			legal_mc.visible = false;
			legal_mc.alpha = 0;
			target_mc.alpha = 0;
			autoPlaying = true;
			autoCannon();
			time_txt.text = String("0:" + gameTime);
			TweenLite.delayedCall(1, gameTimer);
		}
		
		private function gameTimer():void {
			gameTime --;
			var prefix = '0:'
			if(gameTime >= 0){
				if(gameTime < 10){
					prefix = '0:0'
				}
				time_txt.text = String(prefix + gameTime);
				TweenLite.delayedCall(1, gameTimer);
			}else {
				endGame();
			}
		}
		
		private function setLightOnOption(evt:Event):void {
			TweenLite.to(options_mc, .3, {alpha:0});
			if(optionsOpen){
				optionsOpen = !optionsOpen;
				collapseOptions(evt);
			}else{
				optionsOpen = !optionsOpen;
				blinkers = false;
				highlightSelectedOption(innerOptions_mc.lightIcon_mc.iconBg_mc);
				selectLightColor(evt);
			}
		}
		
		private function setLightBlinkOption(evt:Event):void {
			TweenLite.to(options_mc, .3, {alpha:0});
			if(optionsOpen){
				optionsOpen = !optionsOpen;
				collapseOptions(evt);
			}else {
				optionsOpen = !optionsOpen;
				blinkers = true;
				highlightSelectedOption(innerOptions_mc.blinkLightIcon_mc.iconBg_mc);
				selectLightColor(evt);
			}
		}
		
		private function selectLightColor(evt:Event):void {
			outerOptions_mc.spectrum_mc.addEventListener(MouseEvent.MOUSE_MOVE, updateColorPicker);
			outerOptions_mc.spectrum_mc.addEventListener(MouseEvent.CLICK, collapseOptions);
			//TweenLite.to(middleOptions_mc, .2, {alpha:1});
			TweenLite.to(outerOptions_mc, .4, {alpha:1});
		}
		
		private function collapseOptions(evt:Event):void {
			outerOptions_mc.spectrum_mc.removeEventListener(MouseEvent.MOUSE_MOVE, updateColorPicker);
			outerOptions_mc.spectrum_mc.removeEventListener(MouseEvent.CLICK, collapseOptions);
			//TweenLite.to(middleOptions_mc, .2, {alpha:0});
			TweenLite.to(outerOptions_mc, .4, {alpha:0});
		}
		
		private function updateColorPicker(e:MouseEvent):void {
			hexColor = "0x" + bitmapData.getPixel(outerOptions_mc.spectrum_mc.mouseX, outerOptions_mc.spectrum_mc.mouseY).toString(16);
			colorTransform.color = hexColor;
			TweenLite.to(innerOptions_mc.lightIcon_mc.lamp_mc, 0, {tint:hexColor});
			TweenLite.to(innerOptions_mc.blinkLightIcon_mc.lamp_mc, 0, {tint:hexColor});
		}
		
		private function highlightSelectedOption(mc):void {
			if(mc != selectedOption){
				TweenLite.to(selectedOption, 0, {glowFilter:{color:0xff0000, alpha:.1, blurX:0, blurY:0, strength:0, quality:3}});
			}
			TweenLite.to(mc, 0, {glowFilter:{color:0x91e600, alpha:1, blurX:4, blurY:4, strength:6, quality:3}});
			selectedOption = mc;
		}
		
		private function startBlink(mc):void {
			if(mc.parent.blinkers){
				var pauseSpeed = Math.random()*1;
				var lightSpeed = Math.random()*.5;
				TweenLite.to(mc, lightSpeed, {alpha:0, delay:pauseSpeed, onComplete: resetBlink, onCompleteParams:[mc]});
			}
		}
		
		private function resetBlink(mc):void {
			var lightSpeed = Math.random()*.5;
			TweenLite.to(mc, lightSpeed, {alpha:1, onComplete:startBlink, onCompleteParams:[mc]});
		}
		
		private function endGame():void {
			target_mc.alpha = 1;
			gameOver = true;
			endFrame_mc.visible = true;
			killTreeLights();
			TweenLite.to(endFrame_mc, 1, {autoAlpha:1});
			TweenLite.to(cta_mc, 1, {autoAlpha:0});
			TweenLite.to(cannon_mc, .5, {rotation:0});
			TweenLite.delayedCall(.5, updateTargetPath);
		}
		
		private function killTreeLights():void {
			for (var i:uint=0; i< treeHolder_mc.numChildren; i++) {
				var treeLights = treeHolder_mc.getChildAt(i)['lights_mc'];
				TweenLite.to(treeLights, .5, {alpha:0});
			}
		}
		
		private function restartGame(evt:Event):void {
			score_txt.text = '0';
			gameOver = false;
			gameTime = 59;
			TweenLite.delayedCall(1, gameTimer);
			TweenLite.to(endFrame_mc, .5, {autoAlpha:0});
			trackAction('Click_Play_Again');
		}
		
		//*****************************************
		// GAME CONTROLLER
		//*****************************************
		
		private function killAutoPlay(evt:Event):void {
			autoPlaying = false;
			TweenLite.to(cta_mc, .3, {autoAlpha:0});
			gameTime = 15;
			killTreeLights();
			currentScore = 0;
			score_txt.text = String(currentScore);
			trackAction('Click_From_AutoPlay');
		}
		
		private function autoCannon():void {
			if(!gameOver && autoPlaying) {
				var posNeg = int(Math.random()*2) - 1 | 1;
				var rot = (Math.random()*40)*posNeg;
				TweenLite.to(cannon_mc, 3, {rotation:rot, onComplete:fireCannon});
			}
		}
		
		private function fireCannon():void {
			if(!gameOver && autoPlaying) {
				updateTargetPath();
				createSparklies();
				autoCannon();
			}
		}
		
		private function keyDownListener(evt:KeyboardEvent) {
			if(!gameOver) {
				TweenLite.to(cta_mc, .3, {autoAlpha:0});
				TweenLite.killTweensOf(cannon_mc);
				autoPlaying = false;
				target_mc.alpha = 1;
				if (evt.keyCode == leftArrowKey) {
					if(cannon_mc.rotation > leftMax) {
						cannon_mc.rotation -= leftRightInc;
						updateTargetPath();
					}
				}
				if (evt.keyCode == upArrowKey) {
					if(cannon_mc.scaleY < upMax) {
						cannon_mc.scaleY += upDownInc;
						updateTargetPath();
					}
				}
				if (evt.keyCode == rightArrowKey) {
					if(cannon_mc.rotation < rightMax) {
						cannon_mc.rotation += leftRightInc;
						updateTargetPath();
					}
				}
				if (evt.keyCode == downArrowKey) {
					if(cannon_mc.scaleY > downMax) {
						cannon_mc.scaleY -= upDownInc;
						updateTargetPath();
					}
				}
				if(evt.keyCode == spaceBarKey) {
					createSparklies();
				}
			}
		}
		
		private function updateTargetPath():void {
			// TODO - CLEAN UP, CHANGE NOs TO CONSTANTS
			var cannonRotationRectifier = cannon_mc.rotation + rightMax;
			var cannonMidArcX = (stage.stageWidth/2) + (cannon_mc.rotation * (xTrajectoryOffset * xTrajectoryMidArcOffset));
			var cannonMidArcY = ((stage.stageHeight/4) - (cannon_mc.scaleY * 80)) + Math.abs(cannon_mc.rotation*3);
			targetMidArcX = cannonMidArcX;
			targetMidArcY = cannonMidArcY;
			targetDestinationX = (xTrajectoryOffset * cannonRotationRectifier);
			targetDestinationY = stage.stageHeight/6 + ((1.12 - cannon_mc.scaleY)*900);// max = 1.12, min = .8;
			target_mc.x = targetDestinationX;
			target_mc.y = targetDestinationY;
		}
		
		//*****************************************
		// SHOOTING
		//*****************************************
		
		private function setProjectileCoordinates(){
			targetGlobalCoordinates = new Point(cannon_mc.barrelCenter_mc.x,cannon_mc.barrelCenter_mc.y);
			targetGlobalCoordinates = cannon_mc.localToGlobal(targetGlobalCoordinates);
			tracer_mc.x = targetGlobalCoordinates.x;
			tracer_mc.y = targetGlobalCoordinates.y;
		}
		
		private function createSparklies():void {
			if(!shooting){
				shooting = true;
				smokeSprite = new Sprite();
				sparkSprite = new Sprite();
				particles = new Array();
				setProjectileCoordinates();
				projectileHolder_mc.addChild(smokeSprite); 
				projectileHolder_mc.addChild(sparkSprite);
				TweenLite.to(tracer_mc, shootingSpeed, {bezierThrough:[{x:targetMidArcX, y:targetMidArcY}, {x:targetDestinationX, y:targetDestinationY}], orientToBezier:false, ease:Cubic.easeOut, onComplete:killSparkles});
				stage.addEventListener(Event.ENTER_FRAME, frameEvent);
			}
		}
		
		private function killSparkles():void {
			targetHitTest();
			projectileHolder_mc.removeChild(smokeSprite); 
			projectileHolder_mc.removeChild(sparkSprite);
			particle.destroy();
			stage.removeEventListener(Event.ENTER_FRAME, frameEvent);
			shooting = false;
		}
		
		private function explosion():void {
			
		}
		
		private function targetHitTest():void {
			for (var i:uint=0; i< treeHolder_mc.numChildren; i++) {
				var treeGlobalCoordinates = new Point(treeHolder_mc.getChildAt(i).x, treeHolder_mc.getChildAt(i).y);
				treeGlobalCoordinates = treeHolder_mc.localToGlobal(treeGlobalCoordinates);
				// THIS IF TARGETS ANYWHERE ON THE TREE
				if(treeHolder_mc.getChildAt(i).hitTestPoint(tracer_mc.x, tracer_mc.y, true) && !gameOver) {
					currentScore = currentScore + scoreIncrement;
					score_txt.text = String(currentScore);
					var treeLights = treeHolder_mc.getChildAt(i)['lights_mc'];
					treeLights.blinkers = blinkers;
				// THIS IF TARGETS THE TOP OF THE TREE
				//if(tracer_mc.hitTestPoint(treeHolder_mc.getChildAt(i).x, treeHolder_mc.getChildAt(i).y, true)){
					TweenLite.to(treeLights, .3, {alpha: 1, tint:hexColor});
					if(blinkers){
						for (var j:uint=0; j< treeLights.numChildren; j++) {
							startBlink(treeLights.getChildAt(j));
						}
					}
				}
			}
		}
		
		private function frameEvent(evt:Event):void {
			updateParticles();
			counter++; 
			var xpos:Number = tracer_mc.x;
			var ypos:Number = tracer_mc.y; 
			addSparkParticle(xpos, ypos, 5); 
			addSmokeParticle(xpos, ypos, 1); 
		}

		private function addSparkParticle(xpos:Number, ypos:Number, particlecount:int):void {
			for(var i:int=0; i< particlecount; i++) {
				particle = makeParticle(Spark2, sparkSprite, xpos, ypos);
				particle.setVel(randRange(-10,10),randRange(-10,10));
				particle.setScale(randRange(1,2));
				particle.shrink = 0.9;
				particle.gravity = .6;
				particle.drag = 0.6;
				particle.directionRotate = false; 
				particle.updateRotation();
				particles.push(particle);
			}
		}


		private function addSmokeParticle(xpos:Number, ypos:Number, particlecount:int):void {
			for(var i:int=0; i< particlecount; i++) {
				particle = makeParticle(Smoke2, smokeSprite, xpos, ypos);
				particle.setVel(randRange(-0.25,0.25),0);
				particle.clip.scaleX = particle.clip.scaleY = randRange(0.5,0.9);
				particle.clip.alpha = 0.3;
				particle.drag = 0.5;
				particle.fade = 0.95;
				particle.shrink = 1.02;
				particle.gravity = -0.2;
				particles.push(particle);
			}
		}


		private function updateParticles():void {
			var particle:Particle;
			while(particles.length>200) {
				particle = particles.shift();
				particle.disable(); 
				if(!spareParticles[particle.spriteClass])
					spareParticles[particle.spriteClass] = new Array(); 
					spareParticles[particle.spriteClass].push(particle); 
			}
			for(var i:int = 0;i<particles.length;i++) {
				particle = particles[i];
				particle.update();
			}
		}

		private function makeParticle(pclass:Class, target:Sprite, xpos:Number, ypos:Number):Particle {
			if((spareParticles[pclass]) && (spareParticles[pclass].length>0)) {
				particle = spareParticles[pclass].shift(); 
				particle.restart(xpos, ypos); 
			} else{
				particle = new Particle(pclass, target, xpos, ypos);
			}
			return particle; 
		}

		function randRange(min:Number, max:Number) {
		    var randomNum:Number = (Math.random() * (max - min )) + min;
		    return randomNum;
		}

		private function legalRollOverEvent(evt:Event):void {
			TweenLite.to(legal_mc, .3, {autoAlpha:1});
		}
		
		private function legalRollOutEvent(evt:Event):void {
			TweenLite.to(legal_mc, .3, {autoAlpha:0});
		}
		
		private function trackAction(str:String):void {
			trace(str);
			var trackFunction:String = root.loaderInfo.parameters.Measure_this;
			if(trackFunction){
				flash.external.ExternalInterface.call(trackFunction, str);
			}
		}
		
		private function mainClickEvent(evt:Event):void {
			var exitLink:String = root.loaderInfo.parameters.clickTag;
			if(!exitLink){
				exitLink = "http://www.valottery.com";
			}
			var tartgetWindow:String = root.loaderInfo.parameters.clickTARGET;
			if(!tartgetWindow){
				tartgetWindow = "_blank";
			}
			var urlReq:URLRequest = new URLRequest(exitLink);
			navigateToURL(urlReq, tartgetWindow);
		}
	}
}