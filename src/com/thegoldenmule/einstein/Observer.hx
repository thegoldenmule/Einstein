package com.thegoldenmule.einstein;

import com.thegoldenmule.logging.SOSTrace;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.errors.Error;
import flash.events.EventDispatcher;

/**
 * ...
 * @author thegoldenmule
 */

class Observer extends EventDispatcher {
	
	/**
	 * This property is the frame of reference for this object.
	 */
	private var _referenceFrame:Observer;
	public var referenceFrame(getReferenceFrame, setReferenceFrame):Observer;
	
	/**
	 * These properties are defined relative to this observer.
	 */
	private var _polygon:Array<EPoint>;
	private var _time:Float;
	public var time(getTime, null):Float;
	
	/**
	 * These properties are defined relative to the reference frame.
	 */
	public var position:EPoint;
	public var velocity:EPoint;
	public var rotation:Float;
	
	public var view(default, null):MovieClip;
	public var selected:Bool;
	public var applyLorentzTransform:Bool;
	
	private inline static var C_SQUARED:Int = 1;
	public static var SCALE:Int = 100000;
	
	/**
	 * Observers are created as if they are the reference frame.
	 */
	public function new() {
		super();
		
		// default to relativisticness
		applyLorentzTransform = true;
		
		// default to unselected
		selected = false;
		
		// create a basic default polygon
		var size:Int = 1000000;
		_polygon = [
			new EPoint(-size, -size),
			new EPoint(-size, size),
			new EPoint(size, size),
			new EPoint(size, -size)
		];
		
		// these properties don't make sense without a reference frame
		position = new EPoint();
		velocity = new EPoint();
		rotation = 0;
		_time = 0;
		
		// create a view
		view = new MovieClip();
		view.observer = this;
	}
	
	/**
	 * This should only be called if this is the reference frame. It should be
	 * called with how much time has passed (dt).
	 * 
	 * @param	dt
	 */
	public function tick(dt:Float):Void {
		if (null != _referenceFrame) {
			throw new Error("Cannot tick non-reference frame.");
		}
		
		_time += dt;
		
		dispatchEvent(new TimeEvent(TimeEvent.TICK, dt));
	}
	
	/**
	 * Renders observer relative to the reference frame.
	 */
	public function render():Void {
		// prepare graphics
		var graphics:Graphics = view.graphics;
		graphics.clear();
		graphics.beginFill(0, 0);
		graphics.drawCircle(position.x, position.y, 20);
		graphics.endFill();
		graphics.beginFill(null == referenceFrame ? 0xCC0000 : 0xCCCCCC);
		
		// draw polygon relative to reference frame
		var point:EPoint;
		var first:EPoint = null;
		var poly:Array<EPoint> = getPolygonForReferenceFrame();
		for (point in poly) {
			if (null == first) {
				graphics.moveTo(point.x / SCALE, point.y / SCALE);
				first = point;
			} else {
				graphics.lineTo(point.x / SCALE, point.y / SCALE);
			}
		}
		
		// finish figure
		graphics.lineTo(first.x / SCALE, first.y / SCALE);
		graphics.endFill();
	}
	
	/**
	 * Getter for reference frame.
	 * 
	 * @return
	 */
	private function getReferenceFrame():Observer {
		return _referenceFrame;
	}
	
	/**
	 * Setter for reference frame.
	 * 
	 * @param	value
	 * @return
	 */
	private function setReferenceFrame(value:Observer):Observer {
		if (null != _referenceFrame) _referenceFrame.removeEventListener(TimeEvent.TICK, tickHandler);
		
		_referenceFrame = value;
		
		// remove from current reference frame
		if (null != view.parent) view.parent.removeChild(view);
		
		if (null == _referenceFrame || _referenceFrame == this) {
			velocity.x = velocity.y = position.x = position.y = rotation = 0;
		} else {
			/*velocity.subtract(_referenceFrame.velocity);
			position.subtract(_referenceFrame.position);
			rotation -= _referenceFrame.rotation;*/
			
			if (view.contains(_referenceFrame.view)) view.removeChild(_referenceFrame.view);
			
			_referenceFrame.view.addChild(view);
			
			// listen for time
			_referenceFrame.addEventListener(TimeEvent.TICK, tickHandler, false, 0, true);
		}
		
		return _referenceFrame;
	}
	
	/**
	 * Getter for this observer's time.
	 * 
	 * @return
	 */
	private function getTime():Float {
		return applyLorentzTransform ? _time : (null == _referenceFrame) ? _time : _referenceFrame.time;
	}
	
	/**
	 * Getter for polygon. This returns the polygon relative to the reference
	 * frame.
	 * 
	 * @return
	 */
	private function getPolygonForReferenceFrame():Array<EPoint> {
		// get sin + cos of current rotation
		var sin:Float = Math.sin(rotation);
		var cos:Float = Math.cos(rotation);
		
		// perform transformations relative to reference frame
		var poly:Array<EPoint> = new Array<EPoint>();
		var point:EPoint;
		for (point in _polygon) {
			// rotate about origin
			point = new EPoint(
				point.x * cos - point.y * sin,
				point.x * sin + point.y * cos
			);
			
			// Lorentzian transform?
			if (applyLorentzTransform) {
				// remember--position is already relative to the reference frame
				point = new EPoint(
					position.x + point.x * Math.sqrt(1 - (velocity.x * velocity.x) / C_SQUARED),
					position.y + point.y * Math.sqrt(1 - (velocity.y * velocity.y) / C_SQUARED)
				);
			} else {
				point = new EPoint(
					position.x + point.x,
					position.y + point.y
				);
			}
			
			// add it to array
			poly.push(point);
		}
		
		return poly;
	}
	
	/**
	 * Called when time has passed relative to the reference frame.
	 * 
	 * @param	event
	 */
	private function tickHandler(event:TimeEvent):Void {
		// we need to translate the time that has passed for the reference frame
		// into the time that has passed for us using Lorentz transformation.
		_time += event.dt * Math.sqrt(1 - velocity.magnitude() / C_SQUARED);
	}
}