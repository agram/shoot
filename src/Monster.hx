class Monster extends Ent
{
	public static var RANDOM_APPEAR = 20;
	public static var RAY = Std.int(Const.TILE_SIZE / 2);
	public static var RAND_SHOT = 20;
	
	var name:String;
	var direction:Int;
	var flh:Float;
	var death:Int;
	var side:Int;
	var cooldownShoot:Int;
	var mc:h2d.Bitmap;
	
	var points:Array<Int>;
	
	public function new (selected:String, yy:Int, side:Int) {
		super();
		
		Game.inst.monsters.push(this);
		
		points = [];
		y = yy;
		direction = side;
		if (side == 1) {
			x = -100; 
			vx = 1;
		}
		else {
			x = Const.WIDTH + 100;
			vx = -1;
		}
				
		var skin = null;
		name = selected;
		switch (selected ) {
			case 'SPIDER': 
				skin = Game.inst.gfx.monsters[0].ships;
				vx *= 1.5;
				pv = 1;
			case 'BEE': 
				skin = Game.inst.gfx.monsters[1].ships;
				vx *= 1.5;
				pv = 2;
				y = y - 30;
			case  'SHIP':
				skin = Game.inst.gfx.monsters[2].ships;
				pv = 3;
			case  'PHANTOM':
				y = -100;
				x = Std.random(Const.WIDTH);
				skin = Game.inst.gfx.monsters[3].ships;
				pv = 2;
		}
		mc = new h2d.Bitmap(skin, this);
		mc.colorKey = 0xFFFFFFFF;
		this.addChild(mc);
		game.scene.add(this, Const.LAYER_GAME);
		
		//var fg = h2d.Tile.fromColor(0x80FF0000, 1, 1);
		//new h2d.Bitmap(fg, this);
		//
		//game.scene.add(this, Const.LAYER_GAME);		
	}
	
	override public function update ()
	{
		if (name == 'SPIDER') {
			rotation = -Math.PI / 2;	
		}
		else if (name == 'BEE') {
			vy += 0.005 * Math.abs(vx);
			if(direction == 1)
				rotation = Math.atan( -1 * vy / vx);
			else
				rotation = Math.atan( -1 * vy / vx) + Math.PI;

		}
		else if (name == 'SHIP') { 
			if(points.length == 0 || Tools.distance(points[0], x, points[1], y) < 50) {
				points[0] = Std.random(Std.int(Const.WIDTH * 0.95));
				points[1] = Std.random(Std.int(Const.HEIGHT * 0.5));
			}
			vx += (points[0] - x) / Const.WIDTH / 5;
			vy += (points[1] - y) / Const.HEIGHT / 5;
			
			frict = 0.97;
			
			if(vx > 0)
				rotation = Math.atan( -1 * vy / vx);
			else if(vx < 0)
				rotation = Math.atan( -1 * vy / vx) + Math.PI;
		}
		else if (name == 'PHANTOM') { 
			vx = (Hero.inst.x - x) / 200;
			vy = (Hero.inst.y - y) / 200;
			//var facteur = Math.pow(Math.pow(x, 2) + Math.pow(y, 2), 0.5);
			//vx *= facteur/100;
			//vy *= facteur/100;
			frict = 0.92;
			
			if(vx > 0)
				rotation = Math.atan( -1 * vy / vx);
			else if(vx < 0)
				rotation = Math.atan( -1 * vy / vx) + Math.PI;
			
		}

		super.update();

		// COLLISION AVEC LES BORDS
		if (x > Const.WIDTH + 200 || x < - 200) {
			kill();
			return;
		}
		if (y > Const.HEIGHT + 200 || y < - 200) {
			kill();
			return;
		}

		// Flash du monstre quand il est touché
		flash ();

		if (death > 0) {
			if (death > 5) {
				destroy();
				return;
			}
			scaleX = 2 / death;
			scaleY = 2 / death;
			death++;
		}
		
		// TIR DU MONSTRE
		shoot();
	}	
	
	public function shoot()
	{
		cooldownShoot--;
		if (cooldownShoot <= 0)
		{
			if (Std.random(RAND_SHOT) == 0) {
				switch(name) {
				 case 'SPIDER' : 
					var shot = new Shot('GREEN', this);
					shot.x = x;
					shot.y = y + RAY;
					cooldownShoot = 20;
				 case 'BEE' : 
					var shot = new Shot('YELLOW', this);
					shot.x = x;
					shot.y = y + RAY;
					cooldownShoot = 40;
				 case 'SHIP' : 
					var shot = new Shot('MISSILE', this);
					shot.x = x;
					shot.y = y + RAY;
					cooldownShoot = 200;
				}
				hxd.Res.shotMonster.play();
			}
		}
	}
		
	function flash () {
		var inc = Std.int(255 * flh / 255);
		mc.colorAdd = new h3d.Vector(inc);
		flh *= 0.8;
	}
	
	override public function looseLife(nb:Int = 1) 
	{
		hxd.Res.hitMonster.play();
		if(death == 0) {
			pv -= nb;
			if (pv <= 0) {
				Game.inst.countKill++;
				Game.inst.score.text = 'Score : ' + Game.inst.countKill;
				death = 1;
			}
			flh = 1;
		}
	}
		
	override function destroy() 
	{
		var cr = 3;
		for ( i in 0...30 ) {
			var part = new Part(HIT);
			part.pv = Std.random(10)+20;
			part.x = x + part.vx * cr;
			part.y = y + part.vy * cr;
			part.frict = 0.92 + Math.random()*0.04;
		}
		kill();
		hxd.Res.deadMonster.play();
	}
	
	override function kill()
	{
		super.kill();
		Game.inst.monsters.remove(this);
	}

}