package com.thegoldenmule.einstein;
import flash.events.Event;

/**
 * @author thegoldenmule
 */

class TimeEvent extends Event {
	
	public static inline var TICK:String = "timeeventtick";
	
	private var _dt:Float;
	public var dt(getDt, null):Float;
	
	public function new(type:String, dt:Float) {
		super(type);
		
		_dt = dt;
	}
	
	private function getDt():Float {
		return _dt;
	}
}