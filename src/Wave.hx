class Wave
{
	public static var v = 200;
	public static var COOLDOWN_BETWEEN_WAVES = 200;
	public static var COOLDOWN_BETWEEN_MONSTERS = 50;
	
	var current:Int;
	var max:Int;
	var y:Int;
	var side:Int;
		
	var cooldownMonsters:Int;
	
	public function new ()
	{
		max = Game.inst.numeroWave;
		Game.inst.numeroWave++;
		current = 0;
		Game.inst.waves.push(this);
		cooldownMonsters = COOLDOWN_BETWEEN_MONSTERS + Std.random(30);
	}
	
	public function update () 
	{
		if (cooldownMonsters > 0) cooldownMonsters--;
		else {
			var choice = Std.random(35) + 1;
			if (choice < 20) {
				var monster = new Monster ('SPIDER', y, side);
			}
			else if (choice < 30) {
				var monster = new Monster ('BEE', y, side);
			}
			else if (choice < 33) {
				var monster = new Monster ('SHIP', y, side);
			}
			else if (choice < 35) {
				var monster = new Monster ('PHANTOM', y, side);
			}
			y = Std.random(Std.int(Const.HEIGHT * 0.4)) + Monster.RAY;
			side = Std.random(2)+1;
			cooldownMonsters = COOLDOWN_BETWEEN_MONSTERS + Std.random(30);
			
			current++;
			if (current >= max) {
				Game.inst.waves.remove(this);
			}
		}
	}
	
}