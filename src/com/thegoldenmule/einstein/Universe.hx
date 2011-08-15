package com.thegoldenmule.einstein;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;

/**
 * @author thegoldenmule
 */
class Universe extends EventDispatcher {
	
	private var _observers:Array<Observer>;
	public var observers(getObservers, null):Array<Observer>;
	
	private var _referenceFrame:Observer;
	public var referenceFrame(getReferenceFrame, setReferenceFrame):Observer;
	
	private var _time:Float;
	
	public function new() {
		super();
		
		_observers = [];
		_time = 0;
	}
	
	public function start():Void {
		// enterframe tick
		if (0 == _time) _time = Date.now().getTime();
		Lib.current.addEventListener(Event.ENTER_FRAME, tick, false, 0, true);
	}
	
	public function stop():Void {
		
	}
	
	public function addObserver(observer:Observer):Void {
		var i:Int;
		for (i in 0..._observers.length) {
			if (_observers[i] == observer) return;
		}
		
		observer.referenceFrame = _referenceFrame;
		_observers.push(observer);
	}
	
	public function removeObserver(observer:Observer):Void {
		var i:Int;
		for (i in 0..._observers.length) {
			if (_observers[i] == observer) {
				_observers.splice(i, 1);
				break;
			}
		}
	}
	
	public function removeAllObservers():Void {
		stop();
		
		_observers = [];
		_referenceFrame = null;
	}
	
	private function tick(event:Event):Void {
		// figure out our dt
		var newDate:Float = Date.now().getTime();
		var dt:Float = newDate - _time;
		_time = newDate;
		
		// update observers
		update(dt);
		
		// dispatch time event
		dispatchEvent(new TimeEvent(TimeEvent.TICK, dt));
	}
	
	private function update(dt:Float):Void {
		var observer:Observer;
		for (observer in _observers) {
			// integrate
			Integrator.update(observer, dt);
		}
		
		_referenceFrame.tick(dt);
	}
	
	private function getObservers():Array<Observer> {
		// return a copy of the array
		return _observers.slice(0);
	}
	
	private function getReferenceFrame():Observer {
		return _referenceFrame;
	}
	
	private function setReferenceFrame(observer:Observer):Observer {
		// make sure it's added
		addObserver(observer);
		
		// if there is no reference frame, set other observers' frames
		// TODO: if there is currently a frame, we must transform as well
		var i:Int;
		for (i in 0..._observers.length) {
			if (null == observers[i]) {
				observers[i].referenceFrame = observer;
			}
		}
		
		_referenceFrame = observer;
		
		return _referenceFrame;
	}
}