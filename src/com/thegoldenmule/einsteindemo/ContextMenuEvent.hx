package com.thegoldenmule.einsteindemo;
import com.thegoldenmule.einstein.Observer;
import flash.events.Event;

/**
 * ...
 * @author 
 */

class ContextMenuEvent extends Event {
	
	private var _observer:Observer;
	public var observer(getObserver, null):Observer;
	
	public static inline var SWITCH_REFERENCE_FRAMES:String = "switchReferenceFrames";
	
	public function new(type:String, observer:Observer) {
		super(type);
		
		_observer = observer;
	}
	
	private function getObserver():Observer {
		return _observer;
	}
}