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
	public function new(_center:Float,_size:Float,_vel:Float,_invertMass:Float) {
		center=_center;
		size=_size;
		vel=_vel;
		invertMass=_invertMass;
	}
}

class Project {

	var bodies:Array<Body>;
	var dt:Float;//delta time
	var lt:Float=0;//last time
	var tn:Float;//time now
	public function new() {
		System.notifyOnRender(render);
		
		Scheduler.addTimeTask(update, 0, 1 / 60);
		bodies=new Array<Body>();
		var body0:Body=new Body(0,20,100,1);
		var body1:Body=new Body(400,20,-100,1);
		bodies.push(body0);
		bodies.push(body1);
	}

	function update(): Void {
		//delta time calculation
		tn=Scheduler.realTime();
		dt=tn-lt;
		lt=tn;
		//physics
		for (body in bodies) //movement
		{
			body.center+=body.vel*dt;
		}
		for (i in 0...bodies.length) //collision
		{
			var a=bodies[i];
			for (k in (i+1)...bodies.length)
			{
				var b=bodies[k];
				var dp=b.center-a.center;//delta position
				var collided=Math.abs(dp)<(a.size+b.size)/2;
				if(collided)
				{
					var dv=b.vel-a.vel;
					var movingTowardsEachOther=dv*dp<0;
					if(movingTowardsEachOther)
					{
						a.vel*=-1;
						b.vel*=-1;
					}
				}
			}
		}
	}

	function render(framebuffer: Framebuffer): Void {
		var g= framebuffer.g2;
		g.begin();
		drawRects(g);
		g.end();
	}
	function drawRects(graphics:Graphics){
		for (body in bodies)
		{
			graphics.fillRect(body.center-body.size/2,0,body.size,400);
		}
	}
}
