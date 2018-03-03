package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.graphics2.Graphics;
import kha.System;

class Body{
	public var center:Float;
	public var size:Float;
	public var vel:Float;
	public var invertMass:Float; // 1 over mass
	public function new(_center:Float, _size:Float, _vel:Float, _invertMass:Float) {
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
		var body0:Body = new Body(100, 20, 100, 1);
		var body1:Body = new Body(300, 20, -100, 1);
		bodies.push(body0);
		bodies.push(body1);
	}

	function update(): Void {
		//delta time calculation
		tn = Scheduler.realTime();
		dt = tn - lt;
		lt = tn;
		//physics
		for (body in bodies) //movement
		{
			body.center += body.vel * dt;
		}
		for (i in 0...bodies.length) //collision
		{
			var a = bodies[i];
			for (k in (i+1)...bodies.length)
			{
				var b = bodies[k];
				var dp = b.center - a.center;//delta position
				var totalSize = a.size + b.size;
				var collided = Math.abs(dp) < (totalSize) / 2;
				if(collided)
				{
					var dv = b.vel - a.vel;
					var movingTowardsEachOther = dv * dp < 0;
					if(movingTowardsEachOther)
					{
						var totalInvertMass=a.invertMass + b.invertMass;
						var invMassRatioA = a.invertMass / totalInvertMass;
						var invMassRatioB = b.invertMass / totalInvertMass;

						//eliminate overlapping
						var totalOverlap = totalSize/2-Math.abs(dp);
						b.center += totalOverlap * invMassRatioB * (dp / Math.abs(dp));
						a.center -= totalOverlap * invMassRatioA * (dp / Math.abs(dp));

						// bounce
						var BOUNCINESS = 0.5;
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

	function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin();
		drawRects(g);
		g.end();
	}
	function drawRects(graphics:Graphics){
		for (body in bodies)
		{
			graphics.fillRect(body.center - body.size/2.0, 0, body.size, 400);
		}
	}
}
