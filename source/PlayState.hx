package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class PlayState extends FlxState
{
	private var _player:FlxSprite;
	private var _enemies:FlxTypedGroup<FlxSprite>;
	private var _goodies:FlxTypedGroup<FlxSprite>;
	private var _blocks:FlxTypedGroup<FlxSprite>;
	private var _walls:FlxTypedGroup<FlxSprite>;
	private var _movers:FlxGroup;
	private var _nonmovers:FlxGroup;
	
	private var _width:Int = 0;
	private var _height:Int = 0;
	
	private var _cameraColor:Int = 0;
	private var _enemyColor:Int = 0;
	private var _goodyColor:Int = 0;
	private var _blockColor:Int = 0;
	private var _wallColor:Int = 0;
	private var _playerColor:Int = 0;
	
	private var _numEnemies:Int = 0;
	private var _numGoodies:Int = 0;
	private var _numBlocks:Int = 0;
	private var _numWalls:Int = 0;
	private var _fieldSize:Int = 0;
	private var _health:Int = INITIAL_HEALTH;
	private var _availPos:Array<FlxPoint>;
	private var _nextPoint:FlxPoint;
	
	inline static private var ENEMY_RATIO:Float = 0.1;
	inline static private var GOODY_RATIO:Float = 0.08;
	inline static private var BLOCK_RATIO:Float = 0.05;
	inline static private var WALL_RATIO:Float = 0.15;
	
	inline static private var INITIAL_HEALTH:Int = 8;
	inline static private var MIN_ENEMIES:Int = 16;
	inline static private var MIN_GOODIES:Int = 12;
	
	override public function create():Void
	{
		super.create();
		
		var colors:Array<Int> = [];
		colors.push(FlxRandom.color());
		
		for (i in 1...5)
		{
			colors.push( FlxColorUtil.HSVtoARGB( FlxMath.wrapValue( Std.int( FlxColorUtil.RGBtoHSV( colors[ i - 1 ] ).hue ), 72, 359 ), 1, 1 ) );
		}
		
		_playerColor = colors[0];
		_enemyColor = colors[1];
		_goodyColor = colors[2];
		
		_blockColor = colors[3];
		_wallColor = colors[4];
		
		FlxG.camera.bgColor = FlxColor.BLACK;
		FlxG.mouse.visible = false;
		_fieldSize = Std.int(FlxG.width / FlxG.camera.zoom) - 1;
		
		_availPos = [];
		
		for (xPos in 0...(_fieldSize + 1)) {
			for (yPos in 0...(_fieldSize + 1)) {
				_availPos.push(new FlxPoint(xPos, yPos));
			}
		}
		
		_numEnemies = FlxRandom.intRanged(MIN_ENEMIES, Std.int(_fieldSize * _fieldSize * ENEMY_RATIO));
		_numGoodies = FlxRandom.intRanged(MIN_GOODIES, Std.int(_fieldSize * _fieldSize * GOODY_RATIO));
		_numBlocks = FlxRandom.intRanged(1, Std.int(_fieldSize * _fieldSize * BLOCK_RATIO));
		_numWalls = FlxRandom.intRanged(1, Std.int(_fieldSize * _fieldSize * WALL_RATIO));
		
		_enemies = new FlxTypedGroup<FlxSprite>();
		for (i in 0..._numEnemies) _enemies.add(createSprite(_enemyColor));
		add(_enemies);
		
		_goodies = new FlxTypedGroup<FlxSprite>();
		for (i in 0..._numGoodies) _goodies.add(createSprite(_goodyColor));
		add(_goodies);
		
		_blocks = new FlxTypedGroup<FlxSprite>();
		for (i in 0..._numBlocks) _blocks.add(createSprite(_blockColor));
		add(_blocks);
		
		_walls = new FlxTypedGroup<FlxSprite>();
		for (i in 0..._numWalls) _walls.add(createSprite(_wallColor, true));
		add(_walls);
		
		_player = createSprite(FlxColor.WHITE);
		_player.width = 0.5;
		_player.height = 0.5;
		_player.centerOffsets();
		_player.updateHitbox();
		FlxTween.color(_player, 0.5, _playerColor, FlxColor.WHITE, 1, 1, {type: FlxTween.PINGPONG});
		add(_player);
		
		_movers = new FlxGroup();
		_movers.add(_player);
		_movers.add(_enemies);
		
		_nonmovers = new FlxGroup();
		_nonmovers.add(_blocks);
		_nonmovers.add(_walls);
	}
	
	override public function update():Void
	{
		if (FlxG.keys.anyJustPressed(["LEFT", "A"])) _player.x -= 1;
		if (FlxG.keys.anyJustPressed(["UP", "W"])) _player.y -= 1;
		if (FlxG.keys.anyJustPressed(["RIGHT", "D"])) _player.x += 1;
		if (FlxG.keys.anyJustPressed(["DOWN", "S"])) _player.y += 1;
		
		if (_player.x < 0) _player.x = 0;
		if (_player.y < 0) _player.y = 0;
		if (_player.x > _fieldSize) _player.x = _fieldSize;
		if (_player.y > _fieldSize) _player.y = _fieldSize;
		
		FlxG.overlap(_player, _enemies, hitEnemy);
		FlxG.overlap(_player, _goodies, getGoody);
		
		if (FlxG.keys.justPressed.ANY) {
			FlxG.sound.play("Move");
			
			for (enemy in _enemies) {
				if (FlxRandom.chanceRoll()) move(enemy);
			}
		}
		
		FlxG.collide(_movers, _nonmovers, slideBlock);
		FlxG.collide(_nonmovers);
		
		#if debug
		if (FlxG.keys.justPressed.R) resetGame();
		#end
		
		super.update();
	}
	
	private function slideBlock(Object1:Dynamic, Object2:Dynamic):Void
	{
		
	}
	
	private function move(Object:FlxSprite):FlxSprite
	{
		if (FlxRandom.chanceRoll()) {
			switch (FlxRandom.intRanged(0, 3))
			{
				case 0: Object.x -= 1;
				case 1: Object.x += 1;
				case 2: Object.y -= 1;
				case 3: Object.y += 1;
			}
		} else {
			if (_player.x < Object.x ) {
				Object.x --;
			} else if (_player.x > Object.x) {
				Object.x ++;
			} else if (_player.y < Object.y) {
				Object.y --;
			} else if (_player.y > Object.y) {
				Object.y ++;
			}
		}
		
		if (Object.x < 0) Object.x = 0;
		if (Object.x > _fieldSize) Object.x = _fieldSize;
		if (Object.y < 0) Object.y = 0;
		if (Object.y > _fieldSize) Object.y = _fieldSize;
		
		return Object;
	}
	
	private function createSprite(Color:Int, Immovable:Bool = false):FlxSprite
	{
		var newSprite:FlxSprite = new FlxSprite();
		newSprite.makeGraphic(1, 1, Color);
		
		_nextPoint = FlxRandom.getObject(_availPos);
		_availPos.splice(_availPos.indexOf(_nextPoint), 1);
		newSprite.setPosition(_nextPoint.x, _nextPoint.y);
		newSprite.immovable = Immovable;
		
		return newSprite;
	}
	
	private function assignPos(Object:FlxObject):FlxObject
	{
		_nextPoint = FlxRandom.getObject(_availPos);
		_availPos.splice(_availPos.indexOf(_nextPoint), 1);
		Object.setPosition(_nextPoint.x, _nextPoint.y);
		
		return Object;
	}
	
	private function hitEnemy(Player:Dynamic, Enemy:Dynamic):Void
	{
		FlxG.sound.play("Hurt");
		
		if (_health <= 0)
		{
			_player.kill();
			FlxG.camera.flash(FlxColor.RED, 0.25, resetGame);
		}
		else
		{
			_health--;
			cast(Enemy, FlxSprite).kill();
			_numEnemies--;
		}
	}
	
	private function getGoody(Player:Dynamic, Goody:Dynamic):Void
	{
		FlxG.sound.play("Goody");
		cast(Goody, FlxSprite).kill();
		_numGoodies--;
		if (_numGoodies <= 0) FlxG.camera.flash(FlxColor.GREEN, 0.5, winGame);
	}
	
	private function resetGame():Void { FlxG.resetGame(); }
	private function winGame():Void { FlxG.switchState(new WinState()); }
}