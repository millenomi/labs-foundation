package net.infinite_labs.basics;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
public @interface Optional {

	boolean defaultIsNull() default true;
	
	String defaultString() default "";
	
	int defaultInt() default 0;
	long defaultLong() default 0L;
	float defaultFloat() default 0.0f;
	double defaultDouble() default 0.0;
	boolean defaultBoolean() default false;

	
}
