package com.thegoldenmule.einstein;

/**
 * ...
 * @author thegoldenmule
 */

class EPoint {
	
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}
	
	public function clone():EPoint {
		return new EPoint(x, y);
	}
	
	public function subtract(vector:EPoint):Void {
		this.x -= vector.x;
		this.y -= vector.y;
	}
	
	public function add(vector:EPoint):Void {
		this.x += vector.x;
		this.y += vector.y;
	}
	
	public function magnitude():Float {
		return Math.sqrt(x * x + y * y);
	}
}