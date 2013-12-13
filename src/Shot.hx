class Shot extends Ent
{
	public static var WIDTH = 4;
	public static var HEIGHT = 6;
	
	var type:String;
	var pow:Int;
	var cooldown:Int;
	
	public function new (monsterType:String, ship:Dynamic ) {
		super();
		type = monsterType;
		Game.inst.shoots.push(this);
				
		var anim = new h2d.Anim(this);
		anim.colorKey = 0xFFFFFFFF;
		anim.play(anim.frames);
		anim.speed = 30;
		
		switch(type) 
		{
			case 'HERO' :
				vy = -5;
				x = ship.x;
				y = ship.y - Hero.RAY - HEIGHT / 2;
				pow = 1;

				anim.frames = Game.inst.gfx.hero.shots;
				anim.loop = false;
			case 'GREEN' :
				anim.loop = false;
				vy = 2;
				x = ship.x;
				y = ship.y + Monster.RAY + HEIGHT / 2;
				pow = 1;
				
				anim.frames = Game.inst.gfx.monsters[0].shots;
				anim.loop = true;
			case 'YELLOW' :
				vy = 0.5;
				x = ship.x;
				y = ship.y + Monster.RAY + HEIGHT / 2;
				pow = 2;
				
				anim.frames = Game.inst.gfx.monsters[1].shots;
				anim.loop = true;
			case 'MISSILE' :
				pow = 1;
				vx = (Hero.inst.x - ship.x) / 200 ;
				vy = (Hero.inst.y - ship.y) / 200 ;
				x = ship.x;
				y = ship.y + Monster.RAY + HEIGHT / 2;
				if(vx>0)
					rotation = Math.atan( -1 * vy / vx);
				else
					rotation = Math.atan( -1 * vy / vx) + Math.PI;

				anim.frames = Game.inst.gfx.monsters[2].shots;
				anim.loop = true;
		}
	}

	override public function update ()
	{
		super.update();
		
		if (y + WIDTH <= 0 || y - WIDTH > Const.HEIGHT) {
			kill();
			return;
		}

		if ( type == 'HERO') 
		{
			for (oneMonster in Game.inst.monsters) {
				if (Tools.distance(
						oneMonster.x, x, 
						oneMonster.y, y) 
					<= Monster.RAY ) 
				{
					looseLife();
					oneMonster.looseLife(pow);
					
					for( i in 0...3 ){
						var part = new Part(HIT);
						part.x = x;
						part.y = y;						
					}
					return;
				}
			}
		}
		else if (Hero.inst.dead == false && Hero.inst.invulnerability == false)
		{
			if (Tools.distance(Hero.inst.x, x, Hero.inst.y, y) <= Hero.RAY ) 
			{
				looseLife();
				Hero.inst.looseLife(pow);
			}
		}
	}
	
	override function kill()
	{
		super.kill();		
		Game.inst.shoots.remove(this);
	}
	
}