class Tools
{
	public static function distance(x1:Float, x2:Float, y1:Float, y2:Float) 
	{
		return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
	}
	
}