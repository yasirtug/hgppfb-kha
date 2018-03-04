package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics2.Graphics;
import kha.System;

class Vec2{
	var x:Float;
	var y:Float;
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
		a.x *= b;
		a.y *= b;
		return a;
	}
	public static function div(a:Vec2, b:Float):Vec2{
		a.x /= b;
		a.y /= b;
		return a;
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
	public var center:Float;
	public var size:Float;
	public var vel:Float;
	public var invertMass:Float; // 1 over mass
	public function new(_center:Float, _size:Float, _vel:Float, _invertMass:Float){
		center = _center;
		size = _size;
		vel = _vel;
		invertMass = _invertMass;
	}
	public function ApplyImpulse(_amount:Float):Void{
		vel += _amount * invertMass;
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
		var body0:Body = new Body(-180, 400, 0, 0);
		var body1:Body = new Body(580, 400, 0, 0);
		bodies.push(body0);
		bodies.push(body1);
		for(i in 0...10){
			var body:Body = new Body(
				Std.random(301)+50,
				Std.random(40)+1,
				Std.random(100),
				0);
			body.invertMass=1/body.size;
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
			body.center += body.vel * dt;
		}
		for (i in 0...bodies.length){ //collision
		var a = bodies[i];
			for (k in (i+1)...bodies.length)
			{
				var b = bodies[k];
				var dp = b.center - a.center;//delta position
				var totalSize = a.size + b.size;
				var collided = Math.abs(dp) < (totalSize) / 2;
				if(collided){
					var dv = b.vel - a.vel;
					var movingTowardsEachOther = dv * dp < 0;
					if(movingTowardsEachOther){
						var totalInvertMass=a.invertMass + b.invertMass;
						var invMassRatioA = a.invertMass / totalInvertMass;
						var invMassRatioB = b.invertMass / totalInvertMass;

						//eliminate overlapping
						var totalOverlap = totalSize/2-Math.abs(dp);
						b.center += totalOverlap * invMassRatioB * (dp / Math.abs(dp));
						a.center -= totalOverlap * invMassRatioA * (dp / Math.abs(dp));

						// bounce
						var BOUNCINESS = 1;//system conserves energy
						//var BOUNCINESS = 1.04; //system is gaining energy exponentially
						//var BOUNCINESS = 0.96; //system is losing energy exponentially
						var desiredDv = -BOUNCINESS * dv;
						var desiredDvChange = desiredDv - dv;
						//i modified below as more intuitive to me
						var imp = desiredDvChange / totalInvertMass;
						a.ApplyImpulse(-imp);
						b.ApplyImpulse(imp);

						//algebraic method
						//var va = a.vel;
						//var vb = b.vel;
						//a.vel = -a.invertMass * va + 2.0 * a.invertMass * vb + b.invertMass * va;
						//a.vel /= totalInvertMass;
						//b.vel = -b.invertMass * vb + 2.0 * b.invertMass * va + a.invertMass * vb;
						//b.vel /= totalInvertMass;
					}
				}
			}
		}
	}

	function render(framebuffer: Framebuffer):Void{
		var g = framebuffer.g2;
		g.begin();
		drawRects(g);
		g.end();
	}
	function drawRects(graphics:Graphics):Void{
		for (body in bodies)
		{
			graphics.fillRect(body.center - body.size/2.0, 0, body.size, 400);
		}
	}
}
