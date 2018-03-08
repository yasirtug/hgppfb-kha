package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics2.Graphics;
import kha.System;
using kha.graphics2.GraphicsExtension;

class Vec2{
	public var x:Float;
	public var y:Float;
	public function new(x:Float=0, y:Float=0){
		this.x = x;
		this.y = y;
	}
	public static function sum(a:Vec2, b:Vec2):Vec2{
		var c:Vec2 = new Vec2();
		c.x = a.x + b.x;
		c.y = a.y + b.y;
		return c;
	}
	public static function sub(a:Vec2, b:Vec2):Vec2{
		var c:Vec2 = new Vec2();
		c.x = a.x - b.x;
		c.y = a.y - b.y;
		return c;
	}
	public static function pro(a:Vec2, b:Float):Vec2{
		var c:Vec2 = new Vec2();
		c.x = a.x * b;
		c.y = a.y * b;
		return c;
	}
	public static function div(a:Vec2, b:Float):Vec2{
		var c:Vec2 = new Vec2();
		c.x = a.x / b;
		c.y = a.y / b;
		return c;
	}

	public static function dotP(a:Vec2, b:Vec2):Float{
		return a.x * b.x + a.y * b.y;
	}

	public function len2():Float{
		return x*x + y*y;
	}
	public function len():Float{
		return Maths.sqrt( len2() );
	}
}
class Maths{
	public static function sqrt(a:Float):Float{
		var otherSide = 1.0;
		var area = a;
		for(i in 0...100){
			a = (a + otherSide) / 2.0;
			otherSide = area / a;
		}
		return a;
	}
}
class Body{
	public var center:Vec2;
	public var r:Float;
	public var vel:Vec2;
	public var invertMass:Float; // 1 over mass
	public function new(_center:Vec2, _radius:Float, _vel:Vec2, _invertMass:Float){
		center = _center;
		r = _radius;
		vel = _vel;
		invertMass = _invertMass;
	}
	public function ApplyImpulse(_impulse:Vec2):Void{
		vel = Vec2.sum(vel, Vec2.pro(_impulse, invertMass));
	}
}

class Project {
	var bodies:Array<Body>;
	var dt:Float;//delta time
	var lt:Float = 0;//last time
	var tn:Float;//time now
	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1/60);
		bodies = new Array<Body>();
		for(i in 0...100){
			var body:Body = new Body(
				new Vec2(Std.random(400), Std.random(400)),
				Std.random(40) + 1,
				new Vec2(Std.random(40)-20, Std.random(40)-20),
				1.0);
			body.invertMass = 1 / body.r;
			bodies.push(body);
		}
	}

	function update(): Void{
		//delta time calculation
		tn = Scheduler.realTime();
		dt = tn - lt;
		lt = tn;
		//physics
		for (body in bodies){ //movement
			body.center = Vec2.sum(body.center, Vec2.pro(body.vel, dt));
		}
		for (i in 0...bodies.length){ //collision
		var a = bodies[i];
			for (k in (i+1)...bodies.length)
			{
				var b = bodies[k];
				var dp = Vec2.sub(b.center, a.center);//delta position
				var totSize:Float = a.r + b.r;
				var collided = dp.len2() < (totSize * totSize);
				if(collided){
					var dv = Vec2.sub(b.vel, a.vel);
					var movingTowardsEachOther = Vec2.dotP(dv, dp) < 0;
					if(movingTowardsEachOther){
						a.center.x=1000;
						b.center.x=1000;
						// var totalInvertMass=a.invertMass + b.invertMass;
						// var invMassRatioA = a.invertMass / totalInvertMass;
						// var invMassRatioB = b.invertMass / totalInvertMass;

						// //eliminate overlapping
						// var totalOverlap = totalSize/2-Math.abs(dp);
						// b.center += totalOverlap * invMassRatioB * (dp / Math.abs(dp));
						// a.center -= totalOverlap * invMassRatioA * (dp / Math.abs(dp));

						// // bounce
						// var BOUNCINESS = 1;//system conserves energy
						// //var BOUNCINESS = 1.04; //system is gaining energy exponentially
						// //var BOUNCINESS = 0.96; //system is losing energy exponentially
						// var desiredDv = -BOUNCINESS * dv;
						// var desiredDvChange = desiredDv - dv;
						// //i modified below as more intuitive to me
						// var imp = desiredDvChange / totalInvertMass;
						// a.ApplyImpulse(-imp);
						// b.ApplyImpulse(imp);
					}
				}
			}
		}
	}

	function render(framebuffer:Framebuffer):Void{
		var g = framebuffer.g2;
		g.begin();
		drawCircles(g);
		g.end();
	}
	function drawCircles(graphics:Graphics):Void
	{
		for (body in bodies)
		{
			graphics.fillCircle(body.center.x, body.center.y, body.r, 40);
		}
	}
}
