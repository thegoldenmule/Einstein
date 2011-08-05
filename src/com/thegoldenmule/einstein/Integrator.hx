package com.thegoldenmule.einstein;

/**
 * A basic RK4 numerical integrator.
 * 
 * @author thegoldenmule
 */

class Integrator {
	
	public static function update(observer:Observer, dt:Float):Void {
		/*
		 *	Derived from the taylor series...
		 * 
		 *	x( t + h ) =~ x( t ) + h * f + h^2 / 2 * df/dt + h^3 / 6 * d^2f/dt^2 + h^4 / 24 * d^3f/dt^3
		*/
		
		var state:Dynamic = {
			position:observer.position.clone(),
			velocity:observer.velocity.clone()
		};
		
		var k0:Dynamic = state;
		var k1:Dynamic = step(k0, dt);
		var k2:Dynamic = step(k1, (dt * dt) / 2);
		var k3:Dynamic = step(k2, (dt * dt * dt) / 6);
		var k4:Dynamic = step(k3, (dt * dt * dt * dt) / 24);
		
		observer.position.x = k0.position.x + k1.position.x + k2.position.x + k3.position.x + k4.position.x;
		observer.position.y = k0.position.y + k1.position.y + k2.position.y + k3.position.y + k4.position.y;
		
		
	}
	
	private static function step(state:Dynamic, dt:Float):Dynamic {
		var output:Dynamic = {
			position:new EPoint(
				dt * state.velocity.x,
				dt * state.velocity.y
			),
			velocity:state.velocity
		};
		
		return output;
	}
}