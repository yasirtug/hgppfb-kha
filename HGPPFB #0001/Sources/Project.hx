package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

//This code is written by yasirtug in inspiration of tarik kaya's hgppfb 0001

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
		rects.push({centerX:100,centerY:200,width:40,height:40});
		rects.push({centerX:300,centerY:240,width:70,height:80});
	}

	function update(): Void {
		for(rect in rects)
		{
			rect.centerX+=3;
			if(rect.centerX-50>400)
			{
				rect.centerX=-50;
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
		for (rect in rects)
		{
			graphics.fillRect(rect.centerX-rect.width/2,rect.centerY-rect.height/2,rect.width,rect.height);
		}
	}
}
