import hxd.Key in K;

class Hero extends Ent {
	
	public static var skin:h2d.Tile;
	public static var inst : Hero;	

	var cooldownShot:Int;
	var flh:Float;

	public static var RAY = Std.int(Const.TILE_SIZE / 2);
	static var MOVE_SPEED = 1;
	static var LIFEBAR_LENGTH = Const.WIDTH * 0.3;
	static var LIFEBAR_WIDTH = Const.WIDTH * 0.02;
	static var PV_MAX = 5;
	static var COOLDOWN_SHOT = 5;
	static var COOLDOWN_DEATH = 100;
	static var COOLDOWN_DEATH_INVULNERABILITY = 100;
	
	public var lifeBar:h2d.Graphics;
	public var invulnerability:Bool;
	var mc:h2d.Bitmap;
	var cooldownDeath:Int;
	var cooldownDeathInvulnerability:Int;
	
	public function new () {
		super();
		
		inst = this;
		
		pv = PV_MAX;
		
		invulnerability = false;
		
		getSkin();
		
		x = Const.WIDTH * 0.5;
		y = Const.HEIGHT * 0.95 - RAY;
		frict = 0.5;

		// LIFE BAR
		initLifebar();
		
		// FLASH : quand le vaisseau se fait toucher
		flh = 0;
	}	
		
	function getSkin() {
		skin = Game.inst.gfx.hero.ships;
		mc = new h2d.Bitmap(skin, this);
		mc.colorKey = 0xFFFFFFFF;
		this.addChild(mc);
		game.scene.add(this, Const.LAYER_GAME);
		
		var fg = h2d.Tile.fromColor(0x80FF0000, 1, 1);
		new h2d.Bitmap(fg, this);
		game.scene.add(this, Const.LAYER_GAME);		
	}
	
	function initLifebar() {
		var lifeBarTotal = new h2d.Graphics();
		lifeBarTotal.beginFill(0xFF0000);
		lifeBarTotal.drawRect(0, 0, LIFEBAR_LENGTH, LIFEBAR_WIDTH);
		lifeBarTotal.endFill();
		
		lifeBar = new h2d.Graphics();
		lifeBar.beginFill(0x00FF00);
		lifeBar.drawRect(0, 0, LIFEBAR_LENGTH, LIFEBAR_WIDTH);
		lifeBar.endFill();

		lifeBarTotal.addChild(lifeBar);
		lifeBarTotal.x = Const.WIDTH*0.02;
		lifeBarTotal.y = Const.HEIGHT*0.95;		
		Game.inst.scene.add(lifeBarTotal, Const.LAYER_UI);		
	}
	
	override function update() {
		if (dead == true) 
		{
			cooldownDeath--;
			if (cooldownDeath <= 0) 
			{
				var oneLife = Game.inst.lifes.pop();
				Game.inst.scene.removeChild(oneLife);
				if (Game.inst.lifes.length == 0) {
					gameOver();
					return;
				}
				
				getSkin();
				x = Const.WIDTH * 0.5;
				y = Const.HEIGHT * 0.95 - RAY;
				
				dead = false;
				pv = PV_MAX;
				lifeBar.scaleX = 1;
				invulnerability = true;
				cooldownDeathInvulnerability = COOLDOWN_DEATH_INVULNERABILITY;
				flh = 1;
			}
		}

		if (invulnerability == true)
		{
			cooldownDeathInvulnerability--;
			if (cooldownDeathInvulnerability % 10 == 0)
			{
				flh = 1;
			}
			if (cooldownDeathInvulnerability <= 0)
			{
				invulnerability = false;
				flh = 0;
			}
		}
		
		// DETECTION DES TOUCHES
		if (K.isDown(K.LEFT)) vx -= MOVE_SPEED;
		if (K.isDown(K.RIGHT)) vx += MOVE_SPEED;
		if (K.isDown(K.UP)) vy -= MOVE_SPEED;
		if (K.isDown(K.DOWN)) vy += MOVE_SPEED;		
		if (K.isDown(K.SPACE)) shoot();		
		
		cooldownShot--;
		
		// Flash du hero quand il est touché
		var inc = Std.int(-255 * flh / 255);
		this.mc.colorAdd = new h3d.Vector(inc);
		
		if (!invulnerability)
		{
			Game.inst.engine.backgroundColor = Std.int(0xff000000 * flh + 0x000088);
		}
		flh *= 0.5;
		
		// TRAIL : Le vaisseau laisse une trainée derriere lui
		trail();
		
		super.update();  

		// COLLISION AVEC LES BORDS
		if (x < 0) x = 0;
		if (x > Const.WIDTH - RAY) x = Const.WIDTH - RAY;
		if (y < 0) y = 0;
		if (y > Const.HEIGHT*0.95 - RAY) y = Const.HEIGHT*0.95 - RAY;

		// COLLISION AVEC LES MONSTRES
		for(oneMonster in Game.inst.monsters) {
			if (Tools.distance(oneMonster.x, x, oneMonster.y, y) <= Monster.RAY && Hero.inst.dead == false && Hero.inst.invulnerability == false )  {
				looseLife(PV_MAX);
			}
		}
	}
	
	function gameOver() {
		var font = hxd.res.FontBuilder.getFont("Verdana", 12);
		var messageFinal = new h2d.Text(font);
		Game.inst.scene.add(messageFinal, Const.LAYER_UI);
		messageFinal.text = 'Score Final : ' + Game.inst.countKill;
		messageFinal.x = Const.WIDTH*0.05;
		messageFinal.y = Const.HEIGHT * 0.3;
		
	}

	function trail() {
		if (!dead)
		{
			var part = new Part(TRAIL);
			part.fadeType = COLOR_ALPHA_FADE(0xFF00FF);
			part.x = x;
			part.y = y;

		}				
	}
		
	function shoot () {
		if (!dead) {
			if(cooldownShot <= 0) {
				var shot = new Shot('HERO', this);
				cooldownShot = COOLDOWN_SHOT;
				hxd.Res.shotHero.play();
			}
		}  
	}
	
	override public function looseLife(nb:Int = 1) {
		pv = Std.int(Math.max(0, pv-nb));
		lifeBar.scaleX = pv / PV_MAX;

		flh = 1;
		if (pv <= 0) {
			dead = true;
			destroy();
			hxd.Res.deadHero.play();
		}				
	
	}
	
	override function destroy() {
		var cr = 5;
		for ( i in 0...100 ) {
			var part = new Part(HIT);
			part.pv = Std.random(10)+40;
			part.x = x + part.vx * cr;
			part.y = y + part.vy * cr;
			part.frict = 0.92 + Math.random()*0.04;
		}
		parent.removeChild(this);
		cooldownDeath = COOLDOWN_DEATH;
	}
	
}