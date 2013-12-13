enum FadeType {
	NONE;
	COLOR_ALPHA_FADE(color:Int);	
}

enum PartType {
	TRAIL;
	HIT;
}

class Part extends Ent {
	
	public var fadeLimit:Int;
	public var fadeType:FadeType;
	public var mc:h2d.Graphics;
	
	public function new (type: PartType)
	{
		super(Const.LAYER_BACKGROUND);
		fadeType = NONE;
		fadeLimit = 10;
		pv = 10;
		mc = new h2d.Graphics(this);		
		vx = 0;
		vy = 0;

		switch(type) {
			case TRAIL:
				mc.beginFill(0x440000);
				mc.drawCircle(0, 0, Hero.RAY/2*3);
				mc.endFill();
			case HIT:
				pv = 20;
				var angle = Math.random() * 2 * Math.PI;
				var speed = Math.random()*3;
				vx = Math.cos(angle)*speed;
				vy = Math.sin(angle)*speed;
				mc.beginFill(0xffffff, 1);
				mc.drawCircle(0, 0, 1);
				mc.endFill();
				
		}
		
	}
	
	override function kill() {
		super.kill();
		mc.clear();
	}
	
	override public function update ()
	{
		super.update();
		
		pv--;
		
		if (pv == 0) kill();
		
		if (pv < fadeLimit ) 
		{
			var coef = pv / fadeLimit;
			switch(fadeType) {
				case NONE:
				case COLOR_ALPHA_FADE(c): 
					mc.colorAdd = new h3d.Vector(1 - coef, 1 - coef, 1 - coef, coef-1);
			}
		}
		
	}
}