package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;


typedef Rectangle={
	centerX:Float,
	centerY:Float,
	width:Float,
	height:Float
}

class Project {

	var rects:List<Rectangle>;

	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		rects=new List<Rectangle>();
		
	}

	function update(): Void {
		//physics
	}

	function render(framebuffer: Framebuffer): Void {
		var g= framebuffer.g2;
		g.begin();
		drawRects(g);
		g.end();
	}
	function drawRects(graphics:Graphics){
		for (rect in rects)
		{
			graphics.fillRect(rect.centerX-rect.width/2,rect.centerY-rect.height/2,rect.width,rect.height);
		}
	}
}
