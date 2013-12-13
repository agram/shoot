import hxd.Key in K;

typedef Star = { mc:h2d.Graphics, coef:Float }; 

typedef EntGfx = { ships : h2d.Tile, shots : Array<h2d.Tile> }

class Game {

	public var engine : h3d.Engine;
	
	public var scene : h2d.Scene;
	public var gfx : {
		hero : EntGfx,
		monsters : Array<EntGfx>,
	};
	public var starfield:Array<Star>;
	public var ents:Array<Ent>;	
	public var hero:Hero;
	public var shoots:Array<Shot>;
	public var waves:Array<Wave>;
	public var monsters:Array<Monster>;
	
	var cooldown_wave:Int;
	public var numeroWave:Int;
	
	public var countKill:Int;
	
	public var score:h2d.Text;

	public var lifes:Array<h2d.Bitmap>;
	
	function new(engine) {
		gfx = { hero: null, monsters: [] };
		
		this.engine = engine;		
		
		scene = new h2d.Scene();	
		
		scene.setFixedSize(Const.WIDTH, Const.HEIGHT);
		
		ents = [];
		shoots = [];
		waves = [];
		monsters = [];
		lifes = [];
		
		engine.backgroundColor = 0x000088;
		
		cooldown_wave = 0;
		numeroWave = 1;
		countKill = 0;
	}
	
	function init() {
		
//		scene.mouse
		
		initGfx();
		
		initStarfield();

		var console = new h2d.Console(hxd.res.FontBuilder.getFont("Verdana", 12), scene);
		console.addCommand("help", "", [], function() console.log("Pas de commandes implémentées pour le moment"));

		hero = new Hero();
		
		initScore();
		
		// LIFES : affiche les vies
		initLifes();
		
		hxd.System.setLoop(update);
	}
	
	function initGfx() {
		
		var tile = hxd.Res.gfx.toTile();
		var w = Const.TILE_SIZE;
		var h = Const.TILE_SIZE;
		var dx = -w >> 1, dy = -h >> 1;

		// HERO
		var xShip = 0;
		var yShip = 0;
		var ship = tile.sub(xShip, yShip, w, h, dx, dy );
		var xShot = Const.TILE_SIZE;
		var yShot = 0;
		var shots = [];
		for(i in 0...3)
			shots.push(tile.sub(xShot + i * Const.TILE_SIZE, yShot, w, h, dx, dy));
			
		var entHero = { ships : ship, shots : shots }	
		gfx.hero = entHero;
		
		// MONSTRES
		for (i in 0...5) {
			var xShip = 0;
			var yShip = Const.TILE_SIZE * (i + 1);
			var ship = tile.sub(xShip, yShip, w, h, dx, dy);
			var xShot = xShip + Const.TILE_SIZE;
			var yShot = yShip;
			var shots = [];
			for(i in 0...3)
				shots.push(tile.sub(xShot + i * Const.TILE_SIZE, yShot, w, h, dx, dy));
			var entMonstre = { ships : ship, shots : shots }	
			gfx.monsters.push(entMonstre);
		}		
	}
	
	function initScore() {
		hxd.res.Embed.embedFont("Verdana.ttf");
		var font = hxd.res.FontBuilder.getFont("Verdana", 8);
		score = new h2d.Text(font);
		scene.add(score, Const.LAYER_UI);

		score.text = 'Score : ' + countKill;
		score.x = Const.WIDTH*0.5;
		score.y = Const.HEIGHT * 0.90;		
	}
	
	function initLifes() {
		for(i in 0...Const.NB_LIFES) { 
			var skin = Game.inst.gfx.hero.ships;
			var a = new h2d.Bitmap(skin, scene);
			a.colorKey = 0xFFFFFFFF;
			a.x = Const.WIDTH - (i * 5 + 5);
			a.y = 5;
			a.scale(0.4);
			lifes.push(a);
			scene.add(a, Const.LAYER_FOREGROUND);
		}
	}
	
	function update() {
		if (lifes.length == 0) return;		
		
		scene.checkEvents();
		
		
		generateMonsters();	

		updateStarfield();
				
		for (oneWave in waves.copy())
			oneWave.update();
			
		for (oneEnt in ents.copy()) {
			oneEnt.update();
		}
				
		engine.render(scene);		
//		trace(scene.getSpritesCount());
	}
	
	
	// --- Starfield ----
	function updateStarfield() {
		for (oneStar in starfield) {
			oneStar.mc.y += Math.pow(oneStar.coef, 6) * 5;
			if (oneStar.mc.y > Const.HEIGHT) {
				oneStar.mc.y = 0;
				oneStar.mc.x = Std.random(Const.WIDTH);
			}
			
		}		
	}
	
	function generateMonsters () {
		// Toutes les 100 frame, le nombre de monstre augmente de 1 et j'envoie une vague avec un random cooldown d'apparition
		// J'insuffle des monstres en sommant les PV jusqu'a obtenir la difficulté
		if(cooldown_wave <= 0) {
			new Wave();
			cooldown_wave = Wave.COOLDOWN_BETWEEN_WAVES;
		}
		else 
		{
			cooldown_wave--;
		}
	}	
	
	function initStarfield() {
		// STARFIELDS
		starfield = [];
		for (i in 0...200) 
		{			
			var star = { mc: new h2d.Graphics(scene) , coef:Math.random() };
			star.mc.x = Std.random(Const.WIDTH);
			star.mc.y = Std.random(Const.HEIGHT);		
			star.mc.beginFill(0x4444FF);
			star.mc.drawCircle(0, 0, star.coef);
			star.mc.endFill();
			scene.add(star.mc, Const.LAYER_BACKGROUND);
		
			starfield.push(star);
		}		
	}
	
	// --- 
	
	public static var inst : Game;	
	public static function main() {	
		hxd.Res.loader = new hxd.res.Loader(hxd.res.EmbedFileSystem.create(null,{compressSounds:true}));

		hxd.Key.initialize();
		var engine = new h3d.Engine();		
		engine.onReady = function() {
			inst = new Game(engine);
			inst.init();
		};
		engine.init();
	}
	
}