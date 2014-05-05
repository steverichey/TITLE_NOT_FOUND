package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;

class WinState extends FlxState
{
	private var _blocks:FlxTypedGroup<FlxSprite>;
	private var _timer:Float = 0;
	private var _minTime:Float = 2;
	
	inline static private function POSITIONS():Array<Array<Int>> {
		return [	[1, 1], [1, 2], [3, 1], [3, 2], [2, 3], [2, 4],
					[5, 1], [5, 2], [5, 3], [6, 1], [6, 3], [7, 1], [7, 2], [7, 3],
					[9, 1], [9, 2], [9, 3], [10, 3], [11, 1], [11, 2], [11, 3],
					[13, 7], [13, 8], [14, 9], [15, 8], [16, 9], [17, 7], [17, 8], [17, 9],
					[19, 7], [19, 8], [19, 9],
					[21, 7], [21, 8], [21, 9], [21, 10], [22, 8], [23, 9], [24, 7], [24, 8], [24, 9], [24, 10]
				];
	}
	
	override public function create():Void
	{
		super.create();
		
		FlxG.camera.bgColor = FlxRandom.color();
		
		_blocks = new FlxTypedGroup<FlxSprite>();
		
		for (pos in POSITIONS())
		{
			var blockface:FlxSprite = createSprite(pos[0], pos[1]);
			blockface.x += 3;
			blockface.y += 8;
			_blocks.add(blockface);
		}
		
		add(_blocks);
	}
	
	override public function update():Void
	{
		_timer += FlxG.elapsed;
		
		if (_timer > _minTime)
		{
			var block:FlxSprite = _blocks.getRandom();
			
			switch(FlxRandom.intRanged(0, 3))
			{
				case 0: block.x += 1;
				case 1: block.x -= 1;
				case 2: block.y += 1;
				case 3: block.y -= 1;
			}
			
			_timer = 0;
			_minTime -= FlxG.elapsed * 20;
		}
		
		super.update();
	}
	
	private function createSprite(X:Int, Y:Int):FlxSprite
	{
		var newSprite:FlxSprite = new FlxSprite(X, Y);
		newSprite.makeGraphic(1, 1, FlxRandom.color());
		return newSprite;
	}
}